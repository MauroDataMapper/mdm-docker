import ch.qos.logback.classic.encoder.PatternLayoutEncoder
import ch.qos.logback.classic.filter.ThresholdFilter
import ch.qos.logback.classic.spi.ILoggingEvent
import ch.qos.logback.core.ConsoleAppender
import ch.qos.logback.core.filter.Filter
import ch.qos.logback.core.rolling.RollingFileAppender
import ch.qos.logback.core.rolling.TimeBasedRollingPolicy
import ch.qos.logback.core.spi.FilterReply
import grails.util.BuildSettings

String defPattern = '%date{ISO8601} [%thread] %-5level %logger{36} - %msg%n'

File baseDir = BuildSettings.BASE_DIR.canonicalFile

def logDir = new File(baseDir, 'logs').canonicalFile
if (!logDir) logDir.mkdirs()

appender('STDOUT', ConsoleAppender) {
    encoder(PatternLayoutEncoder) {
        pattern = defPattern
    }
    filter(ThresholdFilter) {
        level = ERROR
    }

    filter(HibernateMappingFilter)
}

appender("FILE", RollingFileAppender) {
    file = "${logDir}/mercury.log"
    append = true
    encoder(PatternLayoutEncoder) {
        pattern = defPattern
    }
    filter(HibernateMappingFilter)
    rollingPolicy(TimeBasedRollingPolicy) {
        maxHistory = 90
        fileNamePattern = "${logDir}/mercury.%d{yyyy-MM-dd}.log"
    }
}

root(INFO, ['STDOUT', 'FILE'])
logger('uk.ac.ox.softeng', DEBUG)

class HibernateMappingFilter extends Filter<ILoggingEvent> {

    @Override
    FilterReply decide(ILoggingEvent event) {
        event.message ==~ /.*Specified config option \[importFrom\].*/ ? FilterReply.DENY : FilterReply.NEUTRAL
    }
}
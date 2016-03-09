package com.cisco.cta.taxii.adapter.smoketest;

import java.net.URL;
import java.net.UnknownHostException;

import org.slf4j.LoggerFactory;
import org.springframework.context.Lifecycle;
import org.springframework.http.client.ClientHttpResponse;

import com.cisco.cta.taxii.adapter.AdapterRunner;
import com.cisco.cta.taxii.adapter.RequestFactory;
import com.cisco.cta.taxii.adapter.persistence.TaxiiStatus;
import com.cisco.cta.taxii.adapter.persistence.TaxiiStatus.Feed;
import com.cisco.cta.taxii.adapter.settings.SettingsConfiguration;
import com.google.common.base.Strings;

import ch.qos.logback.classic.Logger;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;


@RequiredArgsConstructor
@Slf4j
public class SmokeTestLifecycle implements Lifecycle {

    private final SettingsConfiguration settingsConfig;
    private final RequestFactory requestFactory;

    @Override
    public void start() {
        // TODO do the smoke testing here
        logSettingsConfig();
        validateOutput();
        validateTaxiiConnectivity();
        AdapterRunner.exit();
    }

    void logSettingsConfig() {
        log.info("Listing configuration parameters ...");
        log.info("=== taxiiService ===");
        log.info("pollEndpoint={}", settingsConfig.taxiiServiceSettings().getPollEndpoint());
        log.info("username={}", settingsConfig.taxiiServiceSettings().getUsername());
        log.info("password={}", Strings.isNullOrEmpty(settingsConfig.taxiiServiceSettings().getPassword()) ? "" : "*****");
        log.info("feeds");
        for (String feed : settingsConfig.taxiiServiceSettings().getFeeds()) {
            log.info("  {}", feed);
        }
        log.info("=== schedule ===");
        log.info("cron={}", settingsConfig.scheduleSettings().getCron());
        log.info("=== transform ===");
        log.info("stylesheet={}", settingsConfig.transformSettings().getStylesheet());
        if (settingsConfig.proxySettings() != null) {
            log.info("=== proxy ===");
            log.info("url={}", settingsConfig.proxySettings().getUrl());
            log.info("authenticationType={}", settingsConfig.proxySettings().getAuthenticationType());
            log.info("username={}", settingsConfig.proxySettings().getUsername());
            log.info("password={}", Strings.isNullOrEmpty(settingsConfig.proxySettings().getPassword()) ? "" : "*****");
        }
    }

    void validateOutput() {
        Logger logger = (Logger) LoggerFactory.getLogger("output");
        if (logger.iteratorForAppenders().hasNext()) {
            log.info("logback.xml, appender-ref is OK");
        } else {
            log.error("Error in logback.xml, no appender-ref is declared inside <logger name=\"output\" ...");
        }
    }

    void validateTaxiiConnectivity() {
        URL endpoint = settingsConfig.taxiiServiceSettings().getPollEndpoint();
        try {
            Feed feed = new TaxiiStatus.Feed();
            feed.setName(settingsConfig.taxiiServiceSettings().getFeeds().iterator().next());
            ClientHttpResponse resp = requestFactory.createPollRequest("smoke-test", feed).execute();

            switch (resp.getRawStatusCode()) {
            case 200:
                log.info("Succesfully connected to {}", endpoint);
                return;
            case 401:
            case 403:
                log.error("Authentication or authorization problem, verify your credentials in application.yml");
                return;
            default:
                log.error("{} returned {} HTTP status code, check your configuration", endpoint, resp.getRawStatusCode());
            }

        } catch (UnknownHostException e) {
            log.error("Unable to resolve host name {}, verify your application.yml and your DNS settings", e.getMessage());
        } catch (Exception e) {
            log.error("Error connecting to " + endpoint, e);
        }
    }

    @Override
    public void stop() {
        // do nothing
    }

    @Override
    public boolean isRunning() {
        return false;
    }

}

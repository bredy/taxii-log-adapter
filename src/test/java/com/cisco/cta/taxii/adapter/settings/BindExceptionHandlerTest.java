/*
   Copyright 2015 Cisco Systems

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.
*/
package com.cisco.cta.taxii.adapter.settings;

import static org.junit.Assert.*;
import static org.mockito.Matchers.contains;
import static org.mockito.Mockito.verify;

import java.io.PrintStream;

import org.junit.Before;
import org.junit.Test;
import org.mockito.Mock;
import org.mockito.MockitoAnnotations;
import org.springframework.context.annotation.AnnotationConfigApplicationContext;
import org.springframework.core.NestedRuntimeException;
import org.springframework.validation.BindException;

import static com.cisco.cta.taxii.adapter.settings.PropertySourceHelper.*;


public class BindExceptionHandlerTest {

    private BindExceptionHandler handler;
    
    @Mock
    private PrintStream err;

    @Before
    public void setUp() throws Exception {
        MockitoAnnotations.initMocks(this);
        handler = new BindExceptionHandler(err);
    }

    @Test
    public void invalidPollEndpoint() throws Exception {
        try (AnnotationConfigApplicationContext ctx = new AnnotationConfigApplicationContext()) {
            ctx.register(SettingsConfiguration.class);
            ctx.getEnvironment().getPropertySources().addFirst(exclude(validProperties(), "taxiiService.pollEndpoint"));
            ctx.refresh();
            fail("The context creation must fail because of invalid configuration.");
        } catch (NestedRuntimeException e) {
            BindException be = (BindException) e.getRootCause();
            handler.handle(be);
            verify(err).println(contains("pollEndpoint has illegal value"));
        }
    }
}

package org.springframework.samples.petclinic;

import jdk.jfr.Configuration;
import jdk.jfr.consumer.RecordedEvent;
import jdk.jfr.consumer.RecordingStream;

import java.io.BufferedWriter;
import java.io.FileWriter;
import java.io.IOException;
import java.io.Writer;
import java.nio.file.Path;
import java.text.ParseException;
import java.util.Map;
import java.util.concurrent.atomic.AtomicBoolean;

public class JFRStreamConsumer {
	static AtomicBoolean started = new AtomicBoolean();

    private final Writer writer;

    public JFRStreamConsumer(Writer writer) {
        this.writer = writer;
    }

    public static void start() {
        if (started.compareAndSet(false, true)) {
            Thread jfrThread = new Thread(JFRStreamConsumer::subscribeJFR);
            jfrThread.start();
        }

    }

    private static void subscribeJFR() {
        System.out.println("subscribeJFR");
        try {
            Writer writer = new BufferedWriter(new FileWriter("events.txt"));
            JFRStreamConsumer consumer = new JFRStreamConsumer(writer);
            Configuration config = null;
            try {
                config = Configuration.getConfiguration("default");
            } catch (IOException | ParseException e) {
                e.printStackTrace();
            }
            System.out.println(config.getSettings());
            // need to subscribe to all default.jfc events
            try (RecordingStream st = new RecordingStream()) {
                for (Map.Entry<String, String> entry : config.getSettings().entrySet()) {
                    String name = entry.getKey();
                    if (name.contains("#enabled") && entry.getValue().equals("true")) {
                        int idx = name.indexOf('#');
                        String eventName = name.substring(0, idx);
                        st.enable(eventName);
                        st.onEvent(eventName, consumer::onEvent);
                    }
                }
                st.onFlush(consumer::onFlush);
                st.start();
            }
        } catch (IOException ex) {

        }
    }

    private void onEvent(RecordedEvent event) {
            //System.out.println(event);
        String serializedEvent = String.valueOf(event);
        try {
            writer.write(serializedEvent);
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    private void onFlush() {
        //System.out.println("FLUSH!!!");
    }
}

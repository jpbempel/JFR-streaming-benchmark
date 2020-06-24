package org.springframework.samples.petclinic;

import jdk.jfr.Configuration;
import jdk.jfr.consumer.RecordedEvent;
import jdk.jfr.consumer.RecordingStream;

import java.io.BufferedWriter;
import java.io.FileWriter;
import java.io.IOException;
import java.io.Writer;
import java.text.ParseException;
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
			try (RecordingStream st = new RecordingStream(Configuration.getConfiguration("profile"))) {
				st.onEvent(consumer::onEvent);
				st.start();
			}
		}
		catch (IOException | ParseException ex) {
			ex.printStackTrace();
		}
	}

	private void onEvent(RecordedEvent event) {
		String serializedEvent = null;
		try {
			serializedEvent = String.valueOf(event.getThread());
		}
		catch (Exception ex) {
			ex.printStackTrace();
			return;
		}
		try {
			writer.write(serializedEvent);
		}
		catch (IOException e) {
			e.printStackTrace();
		}
	}

}

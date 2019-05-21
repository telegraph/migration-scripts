package helpers;

import javax.jcr.Session;
import java.io.BufferedReader;
import java.io.IOException;
import java.io.Writer;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.HashMap;
import java.util.HashSet;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.concurrent.TimeUnit;

public class FileHelper {

	public static String getHMS(long millis) {
		String hms = String.format("%02d:%02d:%02d", TimeUnit.MILLISECONDS.toHours(millis),
				TimeUnit.MILLISECONDS.toMinutes(millis) % TimeUnit.HOURS.toMinutes(1),
				TimeUnit.MILLISECONDS.toSeconds(millis) % TimeUnit.MINUTES.toSeconds(1));
		return hms;
	}

	public static Map<String, Long> getUniqueItemsFromFile(BufferedReader inComponents) throws IOException {
		String line;
		Map<String, Long> counter = new HashMap<>();
		Set<String> elements = new HashSet<>();
		while ((line = inComponents.readLine()) != null) {
			elements.add(line.trim());
		}
		for (String element : elements) {
			counter.put(element, Long.valueOf(0));
		}
		return counter;
	}

	public static void close(Session session) {
		if (session != null && session.isLive()) {
			session.logout();
		}
	}

	public static void close(BufferedReader reader) {
		try {
			if (reader != null) {
				reader.close();
			}
		} catch (IOException e) {
			e.printStackTrace(System.out);
		}
	}

	public static void close(Writer writer) {
		try {
			if (writer != null) {
				writer.flush();
				writer.close();
			}
		} catch (IOException e) {
			e.printStackTrace(System.out);
		}
	}

	public static synchronized void writeLine(Writer writer, String message) {
		try {
			writer.write(message + "\n");
		} catch (IOException e) {
			e.printStackTrace(System.out);
		}
	}

}

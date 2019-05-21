import helpers.FileHelper;
import org.apache.jackrabbit.commons.JcrUtils;
import org.jetbrains.annotations.NotNull;

import javax.jcr.Node;
import javax.jcr.NodeIterator;
import javax.jcr.Repository;
import javax.jcr.RepositoryException;
import javax.jcr.Session;
import javax.jcr.SimpleCredentials;
import javax.jcr.Value;
import java.io.BufferedReader;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.OutputStreamWriter;
import java.io.PrintWriter;
import java.io.Writer;
import java.nio.charset.Charset;
import java.util.HashSet;
import java.util.Properties;
import java.util.Set;

class MigrateTopicPage {

	public enum MigrationResult {
		OK,
		ERROR,
		SKIPPED,
	}

	//properties
	public static final String PRP_ARTICLE_LIST_MIGRATED = "articleListMigrated";
	public static final String PRP_TITLE = "title";
	public static final String PRP_PAGE_TYPE = "pageType";
	public static final String PRP_ORDER_BY_DIRECTION = "orderByDirection";
	public static final String PRP_INCLUDE_OPERATOR = "includeOperator";
	public static final String PRP_EXCLUDE_OPERATOR = "excludeOperator";
	public static final String PRP_OLD_EXCLUDE_TAGS = "excludedTags";
	public static final String PRP_EXCLUDE_TAGS = "excludeTags";
	public static final String PRP_INCLUDE_TAGS = "includeTags";
	public static final String PRP_LIMIT = "limit";
	public static final String PRP_SLING_RESOURCE_TYPE = "sling:resourceType";
	public static final String PRP_OFFSET = "offset";
	public static final String PRP_LAYOUT = "layout";
	public static final String PRP_CQ_TEMPLATE = "cq:template";
	public static final String PRP_JCR_TITLE = "jcr:title";
	public static final String PRP_PAGE_TITLE = "pageTitle";
	public static final String PRP_PAGE_HEADING = "pageHeading";
	public static final String PRP_TAGS = "tags";

	//resource types
	public static final String RT_TELEGRAPH_COMPONENTS_1_RESOURCE_TYPE = "COMPONENT_1_RESOURCE_TYPE";
	public static final String RT_TELEGRAPH_COMPONENTS_2_RESOURCE_TYPE = "COMPONENT_2_RESOURCE_TYPE";
	public static final String RT_TELEGRAPH_COMPONENTS_3_RESOURCE_TYPE = "COMPONENT_3_RESOURCE_TYPE";
	public static final String RT_FOUNDATION_COMPONENTS_PARSYS = "foundation/components/parsys";

	//types
	public static final String PTYPE_NT_UNSTRUCTURED = "nt:unstructured";

	//node names
	public static final String COMPONENT_2_NODE_NAME = "nodename2";
	public static final String PAR_NODE_NAME = "par";
	public static final String PAR_SECTION_1_1_LIST_NODE_NAME = "par_section_1_1/list";

	//others
	public static final String STRUCTURE_BLACKLIST = "structure:blacklist";

	public static void main(String[] args) throws RepositoryException {

		Long start = System.currentTimeMillis();

		Session session = null;
		Writer out = null;
		BufferedReader inFileName = null;

		try {

			Properties prop = new Properties();
			prop.load(MigrateTopicPage.class.getClassLoader().getResourceAsStream("config.properties"));
			String uri = prop.getProperty("crx.server").trim();
			String user = prop.getProperty("crx.user").trim();
			String password = prop.getProperty("crx.password").trim();
			String workspace = prop.getProperty("crx.workspace").trim();
			String scriptVersion = prop.getProperty("script.version").trim();

			String fileName = prop.getProperty("process.input.filename").trim();
			String fileNameInput = "input/" + fileName;
			String fileNameOutput = "output-" + fileName;

			Repository repository = JcrUtils.getRepository(uri);
			session = repository.login(new SimpleCredentials(user, password.toCharArray()), workspace);
			inFileName = new BufferedReader(
					new InputStreamReader(MigrateTopicPage.class.getClassLoader().getResourceAsStream(fileNameInput)));
			out = new PrintWriter(
					new OutputStreamWriter(new FileOutputStream(fileNameOutput), Charset.forName("UTF-8")));

			int counterOK = 0;
			int counterErrors = 0;
			int counterSkipped = 0;
			System.out.println("-------------------");
			System.out.println(" Start processing");
			System.out.println("-------------------");

			String line = null;
			while ((line = inFileName.readLine()) != null) {
				String path = line.trim();
				if (path.length() != 0) {
					MigrationResult result = migrateUneditedTopicPage(session, path, scriptVersion);
					System.out.println(result + ":" + path);
					out.write(result + ":" + path + "\n");
					switch (result) {
					case OK:
						counterOK++;
						break;
					case ERROR:
						counterErrors++;
						break;
					case SKIPPED:
						counterSkipped++;
						break;
					}

				}
			}
			out.flush();

			System.out.println("--------------");
			long elapsedTime = System.currentTimeMillis() - start;
			System.out.println("Migrated (" + counterOK + ") topic pages pages in " + FileHelper.getHMS(elapsedTime)
					+ " hh:mm:ss with " + counterErrors + " Errors and " + counterSkipped + " Skipped");
			System.out.println("--------------");

		} catch (IOException e) {
			e.printStackTrace(System.out);
		} finally {
			FileHelper.close(session);
			FileHelper.close(inFileName);
			FileHelper.close(out);
		}
	}

	private static MigrationResult migrateUneditedTopicPage(Session session, String uneditedTopicPagePath,
			String scriptVersion) {

		try {

			Node parent = session.getNode(uneditedTopicPagePath);
			NodeIterator nodeIterator = parent.getNodes();
			while (nodeIterator.hasNext()) {

				//jrc:node
				Node node = nodeIterator.nextNode();

				//extract include excluded tags
				Node firstListNode = node.getNode(PAR_SECTION_1_1_LIST_NODE_NAME);
				String [] includeTags = getIncludeTags(firstListNode);
				String [] excludeTags = getExcludeTags(firstListNode);

				if (includeTags == null || includeTags.length == 0) {
					return MigrationResult.SKIPPED;
				}

				// jcr:title
				if (node.hasProperty(PRP_JCR_TITLE)) {
					String jcrTitle = node.getProperty(PRP_JCR_TITLE).getValue().getString();
					node.setProperty(PRP_PAGE_TITLE, jcrTitle);
					node.setProperty(PRP_PAGE_HEADING, jcrTitle);
				}

				// cq:template
				if (node.hasProperty(PRP_CQ_TEMPLATE)) {
					node.setProperty(PRP_CQ_TEMPLATE, "/apps/telegraph/template1");
				}

				// sling:resourceType
				if (node.hasProperty(PRP_SLING_RESOURCE_TYPE)) {
					node.setProperty(PRP_SLING_RESOURCE_TYPE, "telegraph/renderer1");
				}

				// Adding the migrated version
				node.setProperty(PRP_ARTICLE_LIST_MIGRATED, scriptVersion);

				// Removing the children sections
				NodeIterator iterator = node.getNodes();
				while (iterator.hasNext()) {
					Node child = iterator.nextNode();
					child.remove();
				}


				Node par = node.addNode(PAR_NODE_NAME);
				par.setPrimaryType(PTYPE_NT_UNSTRUCTURED);
				par.setProperty(PRP_SLING_RESOURCE_TYPE, RT_FOUNDATION_COMPONENTS_PARSYS);

				//article firstListNode
				createNode(par, RT_TELEGRAPH_COMPONENTS_1_RESOURCE_TYPE, "list1", "hero", "1", "5",
						includeTags, excludeTags);
				createNode(par, RT_TELEGRAPH_COMPONENTS_1_RESOURCE_TYPE, "list2", "three-col", "6",
						"3", includeTags, excludeTags);
				createNode(par, RT_TELEGRAPH_COMPONENTS_1_RESOURCE_TYPE, "list3", "two-col", "9", "2",
						includeTags, excludeTags);
				createNode(par, RT_TELEGRAPH_COMPONENTS_1_RESOURCE_TYPE, "list4", "four-col", "11",
						"8", includeTags, excludeTags);

				//commercialUnit
				Node cu = par.addNode(COMPONENT_2_NODE_NAME);
				cu.setProperty(PRP_SLING_RESOURCE_TYPE, RT_TELEGRAPH_COMPONENTS_2_RESOURCE_TYPE);
				cu.setPrimaryType(PTYPE_NT_UNSTRUCTURED);

				//article firstListNode
				createNode(par, RT_TELEGRAPH_COMPONENTS_1_RESOURCE_TYPE, "list5", "three-col", "19",
						"3", includeTags, excludeTags);
				createNode(par, RT_TELEGRAPH_COMPONENTS_1_RESOURCE_TYPE, "list6", "two-col", "22",
						"2", includeTags, excludeTags);
				createNode(par, RT_TELEGRAPH_COMPONENTS_1_RESOURCE_TYPE, "list7", "four-col", "24",
						"8", includeTags, excludeTags);

				//pagination
				createNode(par, RT_TELEGRAPH_COMPONENTS_3_RESOURCE_TYPE, "pagination",
						null, "24", "8", includeTags, excludeTags);

				session.save();
				break;
			}

		} catch (Exception ex) {
			ex.printStackTrace(System.out);
			return MigrationResult.ERROR;
		}

		return MigrationResult.OK;
	}

	@NotNull private static String[] getIncludeTags(Node node) throws RepositoryException {
		// includeTags from tags
		Set<String> tags = new HashSet<>();
		if (node.hasProperty(PRP_TAGS)) {
			Value[] values = node.getProperty(PRP_TAGS).getValues();
			if (values != null && values.length > 0) {
				for (Value value : values) {
					tags.add(value.getString());
				}
			}
		}
		return (String[]) tags.stream().toArray(String[]::new);
	}

	@NotNull
	private static String[] getExcludeTags(Node node) throws RepositoryException {
		Set<String> excluded = new HashSet<>();
		excluded.add(STRUCTURE_BLACKLIST);
		if (node.hasProperty(PRP_OLD_EXCLUDE_TAGS)) {
			Value[] values = node.getProperty(PRP_OLD_EXCLUDE_TAGS).getValues();
			if (values != null && values.length > 0) {
				for (Value value : values) {
					excluded.add(value.getString());
				}
			}
		}
		return (String[]) excluded.stream().toArray(String[]::new);
	}

	private static void createNode(Node par, String resourceType, String nodeName, String layout, String offset,
			String limit, String[] includeTags, String[] excludeTags) throws RepositoryException {
		Node node = par.addNode(nodeName);
		setupCommonsArticleListProperties(node, excludeTags);
		node.setProperty(PRP_SLING_RESOURCE_TYPE, resourceType);
		node.setProperty(PRP_LAYOUT, layout);
		node.setProperty(PRP_OFFSET, offset);
		node.setProperty(PRP_LIMIT, limit);
		node.setProperty(PRP_INCLUDE_TAGS, includeTags);
	}

	private static void setupCommonsArticleListProperties(Node node, String[] excludeTags) throws RepositoryException {
		node.setProperty(PRP_EXCLUDE_TAGS, excludeTags);
		node.setProperty(PRP_EXCLUDE_OPERATOR, "OR");
		node.setProperty(PRP_INCLUDE_OPERATOR, "OR");
		node.setProperty(PRP_ORDER_BY_DIRECTION, "desc");
		node.setProperty(PRP_PAGE_TYPE, "any");
		node.setProperty(PRP_TITLE, "");
	}

}

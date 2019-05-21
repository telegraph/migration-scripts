package helpers;

import javax.jcr.Node;
import javax.jcr.Property;
import javax.jcr.PropertyType;
import javax.jcr.RepositoryException;
import javax.jcr.Value;
import javax.jcr.ValueFormatException;

public class PropertyUtils {

	public static String toString(Value input) throws ValueFormatException, RepositoryException {
		String value = "";
		switch (input.getType()) {
		case PropertyType.BOOLEAN:
			value = String.valueOf(input.getBoolean());
			break;
		case PropertyType.DATE:
			value = String.valueOf(input.getDate().getTime());
			break;
		case PropertyType.STRING:
			value = input.getString();
			break;
		case PropertyType.LONG:
			value = String.valueOf(input.getLong());
			break;
		case PropertyType.DECIMAL:
			value = String.valueOf(input.getDecimal());
			break;
		default:
			value = String.valueOf(input.toString());
		}
		return value;
	}

	private static void copyProperty(Node node, Property property) throws RepositoryException {
		if (property.isMultiple()) {
			if (!"jcr:mixinTypes".equals(property.getName()) &&
					!"jcr:predecessors".equals(property.getName())) {
				node.setProperty(property.getName(), property.getValues());
			}
		} else {
			if (!"jcr:primaryType".equals(property.getName()) &&
					!"jcr:uuid".equals(property.getName()) &&
					!"jcr:createdBy".equals(property.getName()) &&
					!"jcr:isCheckedOut".equals(property.getName()) &&
					!"jcr:baseVersion".equals(property.getName()) &&
					!"jcr:versionHistory".equals(property.getName()) &&
					!"jcr:created".equals(property.getName())
					) {
				node.setProperty(property.getName(), property.getValue());
			}
		}
	}

}

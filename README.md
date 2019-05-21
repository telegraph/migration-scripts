# migration-scripts
Scripts used while migrating pages in AEM

Project has two sections.
# create-pacakge
It has script which is responsible for creating content packages in AEM.  Those content packages will enable moving pages from one AEM environment to the other.

# migrate-topic-page
It has java classes which changed the layout of pages (from old to new layout) by adding/removing/updating jcr nodes.  We ran this migration program on pre-prod environment and then use packaging utility to transfer content to differnt AEM environment.

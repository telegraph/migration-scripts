
INPUT_PATH = 'https://static.telegraph.co.uk/aem/WEB-5598/stage1/all-galleries.txt'

LAST_MODIFIED_DATE = new Date().parse("yyyy-MM-dd", '2022-02-21')

VALID_PAGES = new ArrayList<String>()
EDITED_PAGES = new ArrayList<String>()

def loadPaths() {
    items = new ArrayList<>()

    input = new URL(INPUT_PATH)
    file = new File('/tmp/tmg-lastmodified-galleries-' + System.currentTimeMillis() + '.txt') << input.openStream()
    file.eachLine {line -> items.add(line)}

    return items
}

def checkLastModified(path) {
    def page = pageManager.getPage(path)
    if (page) {
        if (page.lastModified.time.after(LAST_MODIFIED_DATE)) {
            EDITED_PAGES.add(path)
        } else {
            VALID_PAGES.add(path)
        }
    }
}

def saveToFile() {
    modifiedPages = new File('/tmp/Gallery-Modified-Pages-' + System.currentTimeMillis() + '.txt')
    println "Total number of modified pages = ${EDITED_PAGES.size()} are stored in a file ${modifiedPages.path}"

    for (String pagePath : EDITED_PAGES) {
        modifiedPages << pagePath + System.getProperty("line.separator")
    }

    validPages = new File('/tmp/Gallery-Valid-Pages-' + System.currentTimeMillis() + '.txt')
    println "Total number of unmodified pages = ${VALID_PAGES.size()} are stored in a file ${validPages.path}"

    for (String pagePath : VALID_PAGES) {
        validPages << pagePath + System.getProperty("line.separator")
    }
}

loadPaths().each { path -> checkLastModified(path) }
saveToFile()

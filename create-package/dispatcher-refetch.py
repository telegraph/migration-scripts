#!/usr/bin/env python

import json, requests, time, sys, urlparse
from urlparse import urlsplit

core_urls = [{
             "success": "true",
             "results": 47,
             "total": 47,
             "more": "false",
             "offset": 0,
             "hits": [
                { "jcr:content": { "publicUrl": "https://www.telegraph.co.uk/news/data/" } } ,
                { "jcr:content": { "publicUrl": "https://www.telegraph.co.uk/news/defence/" } } ,
                { "jcr:content": { "publicUrl": "https://www.telegraph.co.uk/news/entertainment/" } } ,
                { "jcr:content": { "publicUrl": "https://www.telegraph.co.uk/news/pictures/" } } ,
                { "jcr:content": { "publicUrl": "https://www.telegraph.co.uk/news/uk/" } } ,
                { "jcr:content": { "publicUrl": "https://www.telegraph.co.uk/news/weird/" } } ,
                { "jcr:content": { "publicUrl": "https://www.telegraph.co.uk/news/world/" } } ,
                { "jcr:content": { "publicUrl": "https://www.telegraph.co.uk/news/matt/" } } ,
                { "jcr:content": { "publicUrl": "https://www.telegraph.co.uk/opinion/cartoons/" } } ,
                { "jcr:content": { "publicUrl": "https://www.telegraph.co.uk/opinion/columnists/" } } ,
                { "jcr:content": { "publicUrl": "https://www.telegraph.co.uk/opinion/letters/" } } ,
                { "jcr:content": { "publicUrl": "https://www.telegraph.co.uk/opinion/telegraph-view/" } },
                { "jcr:content": { "publicUrl": "https://www.telegraph.co.uk/obituaries/" } } ,
                { "jcr:content": { "publicUrl": "https://www.telegraph.co.uk/obituaries/celebrity/" } } ,
                { "jcr:content": { "publicUrl": "https://www.telegraph.co.uk/obituaries/culture/" } } ,
                { "jcr:content": { "publicUrl": "https://www.telegraph.co.uk/obituaries/finance/" } } ,
                { "jcr:content": { "publicUrl": "https://www.telegraph.co.uk/obituaries/law/" } } ,
                { "jcr:content": { "publicUrl": "https://www.telegraph.co.uk/obituaries/medicine/" } } ,
                { "jcr:content": { "publicUrl": "https://www.telegraph.co.uk/obituaries/military/" } } ,
                { "jcr:content": { "publicUrl": "https://www.telegraph.co.uk/obituaries/politics/" } } ,
                { "jcr:content": { "publicUrl": "https://www.telegraph.co.uk/obituaries/religion/" } } ,
                { "jcr:content": { "publicUrl": "https://www.telegraph.co.uk/obituaries/royalty/" } } ,
                { "jcr:content": { "publicUrl": "https://www.telegraph.co.uk/obituaries/science/" } } ,
                { "jcr:content": { "publicUrl": "https://www.telegraph.co.uk/obituaries/sport/" } } ,
                { "jcr:content": { "publicUrl": "https://www.telegraph.co.uk/education/" } } ,
                { "jcr:content": { "publicUrl": "https://www.telegraph.co.uk/education/league-tables/" } } ,
                { "jcr:content": { "publicUrl": "https://www.telegraph.co.uk/education/clearing/" } } ,
                { "jcr:content": { "publicUrl": "https://www.telegraph.co.uk/education/opinion/" } } ,
                { "jcr:content": { "publicUrl": "https://www.telegraph.co.uk/education/advice/" } } ,
                { "jcr:content": { "publicUrl": "https://www.telegraph.co.uk/royal-family/" } } ,
                { "jcr:content": { "publicUrl": "https://www.telegraph.co.uk/science/" } } ,
                { "jcr:content": { "publicUrl": "https://www.telegraph.co.uk/weddings/" } } ,
                { "jcr:content": { "publicUrl": "https://www.telegraph.co.uk/weddings/style/" } } ,
                { "jcr:content": { "publicUrl": "https://www.telegraph.co.uk/weddings/traditions/" } } ,
                { "jcr:content": { "publicUrl": "https://www.telegraph.co.uk/weddings/venue/" } } ,
                { "jcr:content": { "publicUrl": "https://www.telegraph.co.uk/weddings/advice/" } } ,
                { "jcr:content": { "publicUrl": "https://www.telegraph.co.uk/weddings/engagement/" } },
                { "jcr:content": { "publicUrl": "https://www.telegraph.co.uk/weddings/essentials/" } } ,
                { "jcr:content": { "publicUrl": "https://www.telegraph.co.uk/investing/" } } ,
                { "jcr:content": { "publicUrl": "https://www.telegraph.co.uk/investing/bonds/" } } ,
                { "jcr:content": { "publicUrl": "https://www.telegraph.co.uk/investing/buy-to-let/" } } ,
                { "jcr:content": { "publicUrl": "https://www.telegraph.co.uk/investing/funds/" } } ,
                { "jcr:content": { "publicUrl": "https://www.telegraph.co.uk/investing/gold/" } } ,
                { "jcr:content": { "publicUrl": "https://www.telegraph.co.uk/investing/isas/" } } ,
                { "jcr:content": { "publicUrl": "https://www.telegraph.co.uk/investing/jisa/" } } ,
                { "jcr:content": { "publicUrl": "https://www.telegraph.co.uk/investing/shares/" } } ,
                { "jcr:content": { "publicUrl": "https://www.telegraph.co.uk/nvesting/sipps/" } }
             ]}]

# Core
if sys.argv[1] == "core":
    exceptions = ['www.telegraph.co.uk/travel/']
    urls = core_urls
else:
    print "Wrong arguments"
    sys.exit(1)

# Dispatcher URL passed as a parameter
if sys.argv[1] == "":
    print "Wrong arguments"
    sys.exit(1)
web = "http://" + sys.argv[2]

for u in xrange(len(urls)):

    session = requests.Session()
    data = urls[u]
    all_lines = data['hits']
    lines=[]

    # remove the exceptions and all the invalid lines from the list
    for i in xrange(len(all_lines)):
        try:
            if any(x in all_lines[i]['jcr:content']['publicUrl'] for x in exceptions):
                continue
            lines.append(all_lines[i]['jcr:content']['publicUrl'])
        except:
            continue

    # ensure homepage is cleared
    lines.append("http://www.telegraph.co.uk/index/")

    # sort the paths based on the number of slashes in the URL, then length
    lines.sort(key=lambda line: (line.count('/'), len(line)))

    path = "/dispatcher/invalidate.cache"
    start_time = time.time()
    counter = 0

    print "Result size", len(lines)

    failed = False
    for i in range(0, len(lines), 30):
        line = []
        print "Index size: ", i, "out of: ", len(lines)
        for i, l in enumerate(lines[i:i+30]):
            try:
                if l.endswith("/"):
                    url=urlsplit(l)
                    line.append(url.path[:-1] + '.html')
            except:
                continue
        if len(line) < 1:
            print "Nothing to do, moving on"
            continue

        try:
            invalidate = '/content/telegraph' + line[0]
            payload = {
                "CQ-Action": "Activate",
                "CQ-Handle": invalidate,
                "CQ-Action-Scope": "ResourceOnly",
                "Content-Type" : "text/plain",
                "Referer" : "about:blank",
                "Server-Agent" : "Communique-Dispatcher",
                "User-Agent" : "python invalidate"
            }
            json_url = "\r\n".join(line)
            counter = counter + len(line)

            print "Invalidating the following paths:"
            print json.dumps(line, indent=3)
            rf_web = session.post(web + path,headers=payload,data=json_url,timeout=60)
            print rf_web.status_code, rf_web.url

        except Exception as e:
            failed = True
            print e
            continue

    # print stats
    print "Total result size", len(lines)
    print "Invalidated result size", counter
    print "Elapsed:", (time.time() - start_time), "seconds"

    if failed:
        print "Exceptions were raised during run, see above"
        sys.exit(1)





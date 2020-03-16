## 用Scrapy框架

1. 引入scrapy的lib，`pip3 install scrapy`

2. 使用命令生成项目的架构：`scrapy startproject mydemo`

```python

from scrapy.crawler import CrawlerProcess
import boto3
import time


class PropublicaSpider(scrapy.Spider):
    # 爬虫名称
    name = "propublica"
    # 1. 需要爬的url地址list
    start_urls = [
        'https://www.propublica.org/topics/healthcare/',
        # 'http://quotes.toscrape.com/page/2/',
    ]
    # 2. 或者使用方法来设置爬虫的url地址list
    # def start_requests(self):
    #
    # urls = [
    #     'http://quotes.toscrape.com/page/1/',
    #     'http://quotes.toscrape.com/page/2/',
    # ]
    # for url in urls:
    #     yield scrapy.Request(url=url, callback=self.parse)
    # 默认的处理返回的html的内容
    def parse(self, response):
        # response中包含了request的请求和response的返回
        result_data = {}
        result_data['url'] = 'https://www.propublica.org/topics/healthcare/'
        series_data = []
        # 可以使用.css 和 .xpath的方式来选择特定的内容
        for series in response.css('div.series-header'):
            # print(series)
            series_item = {}
            # css 选择 html标签名.样式名 ->下面的 html标签名::text属性或者attr(href)属性 get()或者getall()
            series_href = series.css('h4.series-title a::attr(href)').get()
            series_title = series.css('h4.series-title a::text').get()
            series_desc = series.css('p.series-description::text').get()
            series_item['href'] = series_href
            series_item['title'] = series_title
            series_item['desc'] = series_desc
            yield response.follow(series_href, self.parse_series)
            if series_href:
                series_data.append(series_item)
        self.log('Series data: ')
        self.log(series_data)
        print(series_data)
        result_data['series data'] = series_data

        store_data = []
        for store in response.css('div.story-entry'):
            # print(store)
            store_item = {}
            store_url = store.css('h4.hed a::attr(href)').get()
            store_title = store.css('h4.hed a::text').get()
            store_dek = store.css('p.dek::text').get()
            store_item['url'] = store_url
            store_item['title'] = store_title
            store_item['dek'] = store_dek

            if store_url:
                # 调用子url的请求使用follow, Request，follow_all等方法都可以，通过回调函数来处理结果
                yield response.follow(store_url, self.parse_articles)
                store_data.append(store_item)
        #
        # self.log('Store data:')
        # self.log(store_data)
        # result_data['store data'] = store_data
        # print(result_data)
        # save_to_db(result_data)

    def parse_articles(self, response):
        # pass
        # print(response)
        # print("Url:{}".format(response.request.url))
        # print("Title:{}".format(response.css('h2.hed::text').get()))
        # print("Dek:{}".format(response.css('header.article-header').css('p.dek::text').get()))
        # print("Author:{}".format(response.css('div.metadata').css('p a::text').get()))
        # print("CreateDateTime:{}".format(response.css('div.metadata').css('time::attr(datetime)').get()))
        # print("Content:{}".format(response.css('div.article-body').css('p::text').getall()))
        title = response.css('h2.hed::text').get()
        if title is not None:
            item = {
                'url': response.request.url,
                'title': title,
                'description': response.css('header.article-header').css('p.dek::text').get(),
                'author': response.css('div.metadata').css('p a::text').get(),
                'postDatetime': response.css('div.metadata').css('time::attr(datetime)').get(),
                'content': ' '.join(response.css('div.article-body').css('p::text').getall())
            }
            print(item)
            print(item['url'])

    def parse_series(self, response):
        hrefs = response.css('div.description').css('h2.hed a::attr(href)').getall()
        yield from response.follow_all(hrefs, self.parse_articles)
        
```

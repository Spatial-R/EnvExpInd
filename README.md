# Environmental-Exposure-Estimate
This is the repository to assess the environmental exposure estimate on the individual level.

--------------------------------------------------------------------------------------

伯特兰.罗素：
我们的确在思考，但是却思考地如此糟糕，以至于我们时常感觉，也许我们不思考反而更好！

---------------------------------------------------------------------------------

### 前言（我为什么要做这个事情？）

为什么呢？姑且来看如下一段话：

假设你正在想着一盘虾，突然就有人提到了盘子，或者虾，或者一盘虾。这完全出乎你的意料，也没法找到一个理由。这就是一种巧合，巧合存在所有的事物之中。

------------------------------------------------------------------------

已有众多研究从生态学角度（时间序列研究）探讨空气污染或是其他环境暴露对健康结局的影响，同时从个体水平暴露着手研究环境暴露对健康的影响也悄然越来越多，那如何获得个体水平的环境因子暴露量呢？今年年初，帮同事处理了一批数据(空气污染个体评估)，今日兴致使然，将代码整理成若干函数，若各位看官需要，请在公众号(SpatialR)里与我联系。

---------------------------------------

### 数据类型

若需获得个体空气污染暴露量，需要三类数据：**监测站点信息**、**空气污染数据**、**个体信息**

-   监测站点信息：包括**监测站点名称**和监测站点**详细地址信息**。

-   空气污染数据：包括**监测站点名称**、**监测时间**、**污染物浓度数据**。

-   个体信息：包括个体**详细地址信息**和**个体时间信息**(如发病时间、死亡时间、怀孕时间等)。

---------------------------------

### 整体思路

1.  根据监测站点信息地址信息和个体详细地址信息获取其对应的经纬度信息。

2.  根据个体经纬度信息，获取每个个体对应的监测站点编号或浓度差值后的经纬度点。

3.  根据每个个体的时间信息和需评估的时长获得每个个体的评估时长。

4.  根据第二步和第三步获取的信息，获得每个个体的污染物暴露量。


----------------------------

### 第一步：读取相关数据

数据为三类，分别为空气污染数据(pollutant.csv)、监测站点数据(site.csv)和病例数据(patient.csv)。

    individual_data_tem <- read.csv("/home/spatial-r/R/workspace/envrionmenal-exposure/patients.csv",
                                header = T,stringsAsFactors = F)[1000:1020,]
    pollutant_data      <- read.csv("/home/spatial-r/R/workspace/envrionmenal-exposure/pollutant.csv",
                                header = T,stringsAsFactors = F)
    site_data           <- read.csv("/home/spatial-r/R/workspace/envrionmenal-exposure/site.csv",
                                header = T,stringsAsFactors = F)

病例个案数据集individual\_data\_tem包含**病例编号**(编号不重复)、**病例日期**（格式为2014-10-20）和详细地址信息(尽可能详细)。具体格式如下：

<table>
<thead>
<tr class="header">
<th align="center">编号</th>
<th align="left">日期</th>
<th align="left">通讯地址</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td align="center">2564</td>
<td align="left">2015-01-05</td>
<td align="left">湖北省武汉市汉阳区xx路xx号</td>
</tr>
<tr class="even">
<td align="center">2563</td>
<td align="left">2015-01-04</td>
<td align="left">湖北省武汉市江汉区xx路xx号</td>
</tr>
<tr class="odd">
<td align="center">2562</td>
<td align="left">2015-01-04</td>
<td align="left">湖北省武汉市硚口区xx路xx号</td>
</tr>
<tr class="even">
<td align="center">2561</td>
<td align="left">2015-01-03</td>
<td align="left">湖北省武汉市江岸区xx路xx号</td>
</tr>
<tr class="odd">
<td align="center">2560</td>
<td align="left">2015-01-02</td>
<td align="left">湖北省武汉市青山区xx路xx号</td>
</tr>
</tbody>
</table>

空气污染数据集pollutant\_data包含**日期**(格式为2014-10-20)、**监测站点名称**和各类**污染物浓度**。具体格式如下：

<table>
<thead>
<tr class="header">
<th align="left">日期</th>
<th align="left">监测点位</th>
<th align="left">SO2</th>
<th align="left">NO2</th>
<th align="left">PM10</th>
<th align="left">CO</th>
<th align="left">O3</th>
<th align="left">PM2.5</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td align="left">2012-12-27</td>
<td align="left">东湖梨园</td>
<td align="left">7</td>
<td align="left">39.2</td>
<td align="left">70</td>
<td align="left">0.8</td>
<td align="left">6</td>
<td align="left">70.2</td>
</tr>
<tr class="even">
<td align="left">2012-12-27</td>
<td align="left">汉阳月湖</td>
<td align="left">16</td>
<td align="left">42.4</td>
<td align="left">60</td>
<td align="left">0.4</td>
<td align="left">6</td>
<td align="left">65.4</td>
</tr>
<tr class="odd">
<td align="left">2012-12-27</td>
<td align="left">汉口花桥</td>
<td align="left">17</td>
<td align="left">44</td>
<td align="left">74</td>
<td align="left">0.76</td>
<td align="left">6</td>
<td align="left">86.2</td>
</tr>
<tr class="even">
<td align="left">2012-12-27</td>
<td align="left">武昌紫阳</td>
<td align="left">19</td>
<td align="left">46.4</td>
<td align="left">76</td>
<td align="left">0.8</td>
<td align="left">4</td>
<td align="left">86.2</td>
</tr>
<tr class="odd">
<td align="left">2012-12-27</td>
<td align="left">青山钢花</td>
<td align="left">31</td>
<td align="left">39.2</td>
<td align="left">72</td>
<td align="left">0.76</td>
<td align="left">8</td>
<td align="left">100.6</td>
</tr>
</tbody>
</table>

空气污染数据集往往会存在缺少数据，如何进行数据填补，可参考如下代码：

    library(dplyr);library(zoo)
    full.date <- data.frame(date = seq.Date(range(pollutant_data$日期)[1],range(pollutant_data$日期)[2],by="day"))

    pollutant.list <- lapply(unique(pollutant_data$监测点位),function(id){
          dat.tem <- filter(pollutant_data,监测点位 == id)
          pollutant.1 <- merge(full.date,dat.tem,by.x = "date",by.y = "日期",all.x = T)
          pollutant.1 <- arrange(pollutant.1,date); 
          na.num.max <- max(which(is.na(pollutant.1$监测点位)))
          na.num.min <- min(which(is.na(pollutant.1$监测点位)))
          pollutant.1$监测点位  <- ifelse(is.na(pollutant.1$监测点位),id,pollutant.1$监测点位)
          if(na.num.max == nrow(pollutant.1)) {
            mean.value <- apply(pollutant.1[,3:8],2,mean)
            pollutant.1[na.num,] <- c(pollutant.1[na.num,1:2],mean.value)
          }
          if(na.num.min == 1) {
            mean.value <- apply(pollutant.1[,3:8],2,mean)
            pollutant.1[na.num,] <- c(pollutant.1[na.num,1:2],mean.value)
          }
          pollutant.1[,3:8] <- apply(pollutant.1[,3:8],2,na.approx)
          return(pollutant.1)
    })

    pollutant_data_tem <- bind_rows(pollutant.list)

监测站点数据集site\_data包含**监测站点名称**和**监测站点地址信息**。具体格式如下：

<table>
<thead>
<tr class="header">
<th align="left">site</th>
<th align="left">address</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td align="left">汉口花桥</td>
<td align="left">武汉市江岸区花桥二村花桥小学分校</td>
</tr>
<tr class="even">
<td align="left">沌口新区</td>
<td align="left">武汉经济技术开发区公共卫生服务中心</td>
</tr>
<tr class="odd">
<td align="left">汉阳月湖</td>
<td align="left">武汉市汉阳区琴台路月湖公园</td>
</tr>
<tr class="even">
<td align="left">武昌紫阳</td>
<td align="left">武汉市武昌区首义路198号</td>
</tr>
<tr class="odd">
<td align="left">东湖梨园</td>
<td align="left">武汉市东湖生态旅游风景区梨园</td>
</tr>
</tbody>
</table>

#### 第一步: 经纬度数据获取

对于国内用户，可借用百度地图的[API接口](http://lbsyun.baidu.com/index.php?title=webapi/guide/webservice-geocoding)，只需要有详细的地址信息，就可将其转换成经纬度。此处，你还需申请一个百度地图API的秘钥，即可用**geo\_latlon**函数加以实现。

    ########## individual_data_tem 含有病例信息，其中通讯地址变量表示地址信息
    ########## site_data 含有站点信息，其中address变量表示地址信息
    ########## notices：秘钥有日使用次数限制，地址信息需尽可能详细
    site_data <- geo_latlon(data = site_data, add_var = "address", api_key = "你的秘钥")
    individual_data_tem <- geo_latlon(data = individual_data_tem, add_var = "通讯地址", api_key = "你的秘钥")

#### 第二步：获得个体污染物评估编号

总体而言，有两种方式来获得个体污染物的近似估计值：简单粗暴型和精细型。简单粗暴型是根据个体与各监测站点间距离比较后获得最近的监测站点数据作为该个体暴露评估参考值；精细型则是根据监测站点数据和其他协变量数据(如汽车尾气排放等)进行插值（反距离插值、克里金插值或土地利用回归模型）处理后，个体所在经纬度的插值结果作为个体暴露评估的参考值。此处，简单粗暴型和精细型都给予介绍，但精细型局限于反距离插值和克里金插值。

1.  简单粗暴型（最近监测站点作为参考）

简单粗暴型需要两步，第一步需要解决的一个问题是：个体该以哪个监测站点的数据作为暴露评估的参考点？此问题可用`get_refrence_id_simple`函数（最近距离来筛选参考站点）解决；第二个问题则是在知道参考监测点后如何获得个体不同时间点的暴露值呢？此问题则可用`expoure_estimate_simple`函数来解决。

首先，第一个问题解决示例如下：

    ### @ individual_data : the individual dataset from the geo_latlon function
    ### @ individual_lat : varibale which includes the latitude value of the idividual
    ### @ individual_lon : varibale which includes longtitude value of the idividual
    ### @ individual_id  : varibale which includes the id for each individual, fox example: 1,2,3,4 
      
    ### @ site_data : the site dataset from the geo_latlon function
    ### @ site_lat : varibale which includes the latitude value of the site
    ### @ site_lon : varibale which includes the longtitude value of the site
    ### @ site_id  : varibale which includes the id for each site, fox example: site name

    individual_data_tem$refrence_id <- get_refrence_id_simple(individual_data = individual_data_tem, 
                                                          individual_lat = "lat",
                                                          individual_lon ="lon",
                                                          individual_id = "编号",
                                                          site_data = site_data,
                                                          site_lat = "lat",
                                                          site_lon = "lon",
                                                          site_id = "site")
    kable(head(individual_data_tem[,-3]))   #### don't show the address

<table>
<thead>
<tr class="header">
<th align="center">编号</th>
<th align="left">日期</th>
<th align="right">lat</th>
<th align="right">lon</th>
<th align="left">refrence_id</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td align="center">2564</td>
<td align="left">2015-01-05</td>
<td align="right">114.2475</td>
<td align="right">30.51260</td>
<td align="left">汉阳月湖</td>
</tr>
<tr class="even">
<td align="center">2563</td>
<td align="left">2015-01-04</td>
<td align="right">114.2881</td>
<td align="right">30.57810</td>
<td align="left">汉阳月湖</td>
</tr>
<tr class="odd">
<td align="center">2562</td>
<td align="left">2015-01-04</td>
<td align="right">114.2198</td>
<td align="right">30.60389</td>
<td align="left">汉阳月湖</td>
</tr>
<tr class="even">
<td align="center">2561</td>
<td align="left">2015-01-03</td>
<td align="right">114.3103</td>
<td align="right">30.64277</td>
<td align="left">汉口花桥</td>
</tr>
<tr class="odd">
<td align="center">2560</td>
<td align="left">2015-01-02</td>
<td align="right">114.4445</td>
<td align="right">30.63321</td>
<td align="left">青山钢花</td>
</tr>
<tr class="even">
<td align="center">2559</td>
<td align="left">2015-01-02</td>
<td align="right">114.3159</td>
<td align="right">30.53973</td>
<td align="left">武昌紫阳</td>
</tr>
</tbody>
</table>

此处可知，对于编号2564需采用监测点汉阳月湖的空气污染浓度监测数据作为参考来获取暴露值。

在获得参考监测站点后，我们通过`expoure_estimate_simple`来获得个体暴露值，具体示例代码如下：

      ### @ individual_data: the dataset which inludes the refrence id, indi_id and frist_date
      ### @ individual_id: varibale which includes the id for each individual, fox example: 1,2,3,4 
      ### @ refrence_id: varibale which tell you the target site id
      ### @ frist_date: varibale which has the date information
      ### @ estimate_interval: how long do you need to measure, for example: 0:30
      ### @ pollutant_data: the dataset which indludes the pollutant and site informatin
      ### @ pollutant_site: varibale name which includes the site infromation
      ### @ pollutant_date: varibale name which includes the date infromation for pollutant
      ### @ pollutant_name: which pollutant need to be estimated 

    exposure.simple <- expoure_estimate_simple(individual_data = individual_data_tem,
                                               individual_id = "编号",
                                               refrence_id = "refrence_id",
                                               frist_date = "日期",
                                               pollutant_data = pollutant_data_tem,
                                               pollutant_site = "监测点位",
                                               pollutant_date = "date",
                                               pollutant_name = c("PM10","SO2"),
                                               estimate_interval = c(0:10))

    kable(head(exposure.simple$PM10),digits= 1)   #### PM10 estimation

<table>
<thead>
<tr class="header">
<th align="left">id</th>
<th align="left">day.0</th>
<th align="left">day.1</th>
<th align="left">day.2</th>
<th align="left">day.3</th>
<th align="left">day.4</th>
<th align="left">day.5</th>
<th align="left">day.6</th>
<th align="left">day.7</th>
<th align="left">day.8</th>
<th align="left">day.9</th>
<th align="left">day.10</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td align="left">2564</td>
<td align="left">130</td>
<td align="left">80</td>
<td align="left">94</td>
<td align="left">142</td>
<td align="left">214</td>
<td align="left">208</td>
<td align="left">236</td>
<td align="left">220</td>
<td align="left">162</td>
<td align="left">202</td>
<td align="left">206</td>
</tr>
<tr class="even">
<td align="left">2563</td>
<td align="left">80</td>
<td align="left">94</td>
<td align="left">142</td>
<td align="left">214</td>
<td align="left">208</td>
<td align="left">236</td>
<td align="left">220</td>
<td align="left">162</td>
<td align="left">202</td>
<td align="left">206</td>
<td align="left">220</td>
</tr>
<tr class="odd">
<td align="left">2562</td>
<td align="left">80</td>
<td align="left">94</td>
<td align="left">142</td>
<td align="left">214</td>
<td align="left">208</td>
<td align="left">236</td>
<td align="left">220</td>
<td align="left">162</td>
<td align="left">202</td>
<td align="left">206</td>
<td align="left">220</td>
</tr>
<tr class="even">
<td align="left">2561</td>
<td align="left">84</td>
<td align="left">134</td>
<td align="left">228</td>
<td align="left">234</td>
<td align="left">216</td>
<td align="left">178</td>
<td align="left">146</td>
<td align="left">198</td>
<td align="left">194</td>
<td align="left">230</td>
<td align="left">200</td>
</tr>
<tr class="odd">
<td align="left">2560</td>
<td align="left">140</td>
<td align="left">266</td>
<td align="left">310</td>
<td align="left">238</td>
<td align="left">198</td>
<td align="left">166</td>
<td align="left">210</td>
<td align="left">204</td>
<td align="left">220</td>
<td align="left">212</td>
<td align="left">146</td>
</tr>
<tr class="even">
<td align="left">2559</td>
<td align="left">154</td>
<td align="left">208</td>
<td align="left">206</td>
<td align="left">210</td>
<td align="left">194</td>
<td align="left">136</td>
<td align="left">192</td>
<td align="left">182</td>
<td align="left">202</td>
<td align="left">176</td>
<td align="left">136</td>
</tr>
</tbody>
</table>

    kable(head(exposure.simple$SO2),digits= 1)    #### SO2 estimation

<table>
<thead>
<tr class="header">
<th align="left">id</th>
<th align="left">day.0</th>
<th align="left">day.1</th>
<th align="left">day.2</th>
<th align="left">day.3</th>
<th align="left">day.4</th>
<th align="left">day.5</th>
<th align="left">day.6</th>
<th align="left">day.7</th>
<th align="left">day.8</th>
<th align="left">day.9</th>
<th align="left">day.10</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td align="left">2564</td>
<td align="left">20</td>
<td align="left">8</td>
<td align="left">18</td>
<td align="left">24</td>
<td align="left">31</td>
<td align="left">37</td>
<td align="left">40</td>
<td align="left">35</td>
<td align="left">24</td>
<td align="left">27</td>
<td align="left">47</td>
</tr>
<tr class="even">
<td align="left">2563</td>
<td align="left">8</td>
<td align="left">18</td>
<td align="left">24</td>
<td align="left">31</td>
<td align="left">37</td>
<td align="left">40</td>
<td align="left">35</td>
<td align="left">24</td>
<td align="left">27</td>
<td align="left">47</td>
<td align="left">60</td>
</tr>
<tr class="odd">
<td align="left">2562</td>
<td align="left">8</td>
<td align="left">18</td>
<td align="left">24</td>
<td align="left">31</td>
<td align="left">37</td>
<td align="left">40</td>
<td align="left">35</td>
<td align="left">24</td>
<td align="left">27</td>
<td align="left">47</td>
<td align="left">60</td>
</tr>
<tr class="even">
<td align="left">2561</td>
<td align="left">25</td>
<td align="left">29</td>
<td align="left">47</td>
<td align="left">52</td>
<td align="left">52</td>
<td align="left">44</td>
<td align="left">39</td>
<td align="left">44</td>
<td align="left">58</td>
<td align="left">82</td>
<td align="left">52</td>
</tr>
<tr class="odd">
<td align="left">2560</td>
<td align="left">31</td>
<td align="left">60</td>
<td align="left">56</td>
<td align="left">50</td>
<td align="left">47</td>
<td align="left">43</td>
<td align="left">47</td>
<td align="left">72</td>
<td align="left">108</td>
<td align="left">54</td>
<td align="left">72</td>
</tr>
<tr class="even">
<td align="left">2559</td>
<td align="left">47</td>
<td align="left">40</td>
<td align="left">44</td>
<td align="left">41</td>
<td align="left">41</td>
<td align="left">28</td>
<td align="left">35</td>
<td align="left">62</td>
<td align="left">84</td>
<td align="left">44</td>
<td align="left">52</td>
</tr>
</tbody>
</table>

------------------------------------------------------------------------

1.  精细型

精细型此处只提供两种，一种是反距离插值，一种是克里金插值。这两种类型都需调用**gstat**这个程序包，所以，你懂得：install\_packages("gstat")

    pollutant_data_tem_idw <- merge(pollutant_data_tem,site_data[,c(1,3,4)],by.x = "监测点位",by.y = "site", all.x = T)

    exposure.idw <- get_refrence_data_idw(individual_data = individual_data_tem,
                                          individual_id = "编号",
                                          frist_date ="日期",
                                          individual_lat ="lat",
                                          individual_lon ="lon",
                                          pollutant_data = pollutant_data_tem_idw,
                                          pollutant_date = "date",
                                          pollutant_site_lat = "lat",
                                          pollutant_site_lon = "lon",
                                          pollutant_name = c("PM10","SO2"),
                                          estimate_interval = c(0:10))  

  
    kable(head(exposure.idw$PM10),digits = 1)   #### PM10 estimation

<table>
<thead>
<tr class="header">
<th align="right">day.0</th>
<th align="right">day.1</th>
<th align="right">day.2</th>
<th align="right">day.3</th>
<th align="right">day.4</th>
<th align="right">day.5</th>
<th align="right">day.6</th>
<th align="right">day.7</th>
<th align="right">day.8</th>
<th align="right">day.9</th>
<th align="right">day.10</th>
<th align="right">id</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td align="right">196.1</td>
<td align="right">198.6</td>
<td align="right">146.7</td>
<td align="right">191.5</td>
<td align="right">216.3</td>
<td align="right">204.3</td>
<td align="right">213.0</td>
<td align="right">152.5</td>
<td align="right">102.2</td>
<td align="right">88.6</td>
<td align="right">135.4</td>
<td align="right">2564</td>
</tr>
<tr class="even">
<td align="right">220.2</td>
<td align="right">198.6</td>
<td align="right">202.7</td>
<td align="right">154.3</td>
<td align="right">199.5</td>
<td align="right">223.4</td>
<td align="right">213.1</td>
<td align="right">217.2</td>
<td align="right">142.8</td>
<td align="right">102.7</td>
<td align="right">91.8</td>
<td align="right">2563</td>
</tr>
<tr class="odd">
<td align="right">227.0</td>
<td align="right">194.7</td>
<td align="right">199.9</td>
<td align="right">149.1</td>
<td align="right">187.8</td>
<td align="right">216.8</td>
<td align="right">212.0</td>
<td align="right">217.5</td>
<td align="right">146.4</td>
<td align="right">97.6</td>
<td align="right">91.6</td>
<td align="right">2562</td>
</tr>
<tr class="even">
<td align="right">191.0</td>
<td align="right">224.1</td>
<td align="right">195.2</td>
<td align="right">202.2</td>
<td align="right">150.3</td>
<td align="right">184.1</td>
<td align="right">217.6</td>
<td align="right">228.4</td>
<td align="right">225.2</td>
<td align="right">140.1</td>
<td align="right">98.8</td>
<td align="right">2561</td>
</tr>
<tr class="odd">
<td align="right">141.6</td>
<td align="right">186.6</td>
<td align="right">209.8</td>
<td align="right">195.9</td>
<td align="right">203.9</td>
<td align="right">155.1</td>
<td align="right">188.2</td>
<td align="right">222.5</td>
<td align="right">245.9</td>
<td align="right">229.7</td>
<td align="right">152.5</td>
<td align="right">2560</td>
</tr>
<tr class="even">
<td align="right">136.1</td>
<td align="right">176.1</td>
<td align="right">202.2</td>
<td align="right">182.2</td>
<td align="right">192.2</td>
<td align="right">136.3</td>
<td align="right">194.0</td>
<td align="right">210.2</td>
<td align="right">206.1</td>
<td align="right">208.1</td>
<td align="right">153.9</td>
<td align="right">2559</td>
</tr>
</tbody>
</table>

    kable(head(exposure.idw$SO2),digits= 1)   #### SO2 estimation

<table>
<thead>
<tr class="header">
<th align="right">day.0</th>
<th align="right">day.1</th>
<th align="right">day.2</th>
<th align="right">day.3</th>
<th align="right">day.4</th>
<th align="right">day.5</th>
<th align="right">day.6</th>
<th align="right">day.7</th>
<th align="right">day.8</th>
<th align="right">day.9</th>
<th align="right">day.10</th>
<th align="right">id</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td align="right">52.9</td>
<td align="right">33.1</td>
<td align="right">27.5</td>
<td align="right">35.9</td>
<td align="right">40.7</td>
<td align="right">41.3</td>
<td align="right">36.6</td>
<td align="right">30.7</td>
<td align="right">24.4</td>
<td align="right">13.6</td>
<td align="right">26.2</td>
<td align="right">2564</td>
</tr>
<tr class="even">
<td align="right">72.1</td>
<td align="right">53.0</td>
<td align="right">33.7</td>
<td align="right">28.3</td>
<td align="right">37.6</td>
<td align="right">43.2</td>
<td align="right">43.3</td>
<td align="right">36.7</td>
<td align="right">27.3</td>
<td align="right">22.4</td>
<td align="right">15.4</td>
<td align="right">2563</td>
</tr>
<tr class="odd">
<td align="right">73.3</td>
<td align="right">53.2</td>
<td align="right">35.1</td>
<td align="right">29.1</td>
<td align="right">35.9</td>
<td align="right">43.7</td>
<td align="right">44.6</td>
<td align="right">38.4</td>
<td align="right">27.2</td>
<td align="right">22.5</td>
<td align="right">15.2</td>
<td align="right">2562</td>
</tr>
<tr class="even">
<td align="right">50.8</td>
<td align="right">81.0</td>
<td align="right">57.2</td>
<td align="right">40.2</td>
<td align="right">34.3</td>
<td align="right">40.6</td>
<td align="right">47.4</td>
<td align="right">48.8</td>
<td align="right">43.4</td>
<td align="right">28.1</td>
<td align="right">25.1</td>
<td align="right">2561</td>
</tr>
<tr class="odd">
<td align="right">58.7</td>
<td align="right">44.5</td>
<td align="right">84.2</td>
<td align="right">57.4</td>
<td align="right">37.5</td>
<td align="right">32.4</td>
<td align="right">36.8</td>
<td align="right">40.3</td>
<td align="right">43.0</td>
<td align="right">43.3</td>
<td align="right">30.7</td>
<td align="right">2560</td>
</tr>
<tr class="even">
<td align="right">51.9</td>
<td align="right">44.0</td>
<td align="right">83.8</td>
<td align="right">61.8</td>
<td align="right">35.0</td>
<td align="right">28.0</td>
<td align="right">40.9</td>
<td align="right">41.0</td>
<td align="right">43.9</td>
<td align="right">39.9</td>
<td align="right">46.7</td>
<td align="right">2559</td>
</tr>
</tbody>
</table>

    example.date <- range(pollutant_data_tem$date)[2]
    test.pollutant <- filter(pollutant_data_tem,date == example.date)[,c(2,5)]
    test.pollutant <- merge(test.pollutant,site_data,by.x="监测点位",by.y="site")
    coordinates(test.pollutant) = ~lat + lon
    m <- fit.variogram(variogram(PM10~1, test.pollutant), vgm(1, "Sph", 200, 1))

    estimate.krige <- get_refrence_data_krige(individual_data = individual_data_tem,
                                         individual_id = "编号",
                                         frist_date = "日期",
                                         individual_lat = "lat",
                                         individual_lon = "lon",
                                         pollutant_data = pollutant_data_tem_idw,
                                         pollutant_date = "date",
                                         pollutant_site_lat = "lat",
                                         pollutant_site_lon = "lon",
                                         pollutant_name = c("PM10","SO2"),
                                         estimate_interval = c(0:10),
                                         krige_model = m,
                                         nmax = 7,
                                         krige_method = "med")

  
    kable(head(estimate.krige$PM10),digits = 1)   #### PM10 estimation

<table>
<thead>
<tr class="header">
<th align="right">day.0</th>
<th align="right">day.1</th>
<th align="right">day.2</th>
<th align="right">day.3</th>
<th align="right">day.4</th>
<th align="right">day.5</th>
<th align="right">day.6</th>
<th align="right">day.7</th>
<th align="right">day.8</th>
<th align="right">day.9</th>
<th align="right">day.10</th>
<th align="right">id</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td align="right">194</td>
<td align="right">198</td>
<td align="right">146</td>
<td align="right">178</td>
<td align="right">210</td>
<td align="right">206</td>
<td align="right">214</td>
<td align="right">146</td>
<td align="right">102</td>
<td align="right">88</td>
<td align="right">130</td>
<td align="right">2564</td>
</tr>
<tr class="even">
<td align="right">220</td>
<td align="right">198</td>
<td align="right">202</td>
<td align="right">150</td>
<td align="right">188</td>
<td align="right">216</td>
<td align="right">208</td>
<td align="right">214</td>
<td align="right">142</td>
<td align="right">102</td>
<td align="right">88</td>
<td align="right">2563</td>
</tr>
<tr class="odd">
<td align="right">220</td>
<td align="right">194</td>
<td align="right">198</td>
<td align="right">146</td>
<td align="right">178</td>
<td align="right">210</td>
<td align="right">206</td>
<td align="right">214</td>
<td align="right">146</td>
<td align="right">102</td>
<td align="right">88</td>
<td align="right">2562</td>
</tr>
<tr class="even">
<td align="right">192</td>
<td align="right">220</td>
<td align="right">194</td>
<td align="right">202</td>
<td align="right">150</td>
<td align="right">188</td>
<td align="right">216</td>
<td align="right">208</td>
<td align="right">216</td>
<td align="right">142</td>
<td align="right">98</td>
<td align="right">2561</td>
</tr>
<tr class="odd">
<td align="right">136</td>
<td align="right">178</td>
<td align="right">220</td>
<td align="right">198</td>
<td align="right">202</td>
<td align="right">150</td>
<td align="right">194</td>
<td align="right">216</td>
<td align="right">208</td>
<td align="right">214</td>
<td align="right">142</td>
<td align="right">2560</td>
</tr>
<tr class="even">
<td align="right">136</td>
<td align="right">178</td>
<td align="right">220</td>
<td align="right">198</td>
<td align="right">202</td>
<td align="right">150</td>
<td align="right">194</td>
<td align="right">216</td>
<td align="right">208</td>
<td align="right">214</td>
<td align="right">142</td>
<td align="right">2559</td>
</tr>
</tbody>
</table>

    kable(head(estimate.krige$SO2),digits = 1)   #### SO2 estimation

<table>
<thead>
<tr class="header">
<th align="right">day.0</th>
<th align="right">day.1</th>
<th align="right">day.2</th>
<th align="right">day.3</th>
<th align="right">day.4</th>
<th align="right">day.5</th>
<th align="right">day.6</th>
<th align="right">day.7</th>
<th align="right">day.8</th>
<th align="right">day.9</th>
<th align="right">day.10</th>
<th align="right">id</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td align="right">58.0</td>
<td align="right">35.0</td>
<td align="right">28</td>
<td align="right">37</td>
<td align="right">42</td>
<td align="right">46</td>
<td align="right">40</td>
<td align="right">29</td>
<td align="right">25</td>
<td align="right">12</td>
<td align="right">28</td>
<td align="right">2564</td>
</tr>
<tr class="even">
<td align="right">82.0</td>
<td align="right">58.0</td>
<td align="right">39</td>
<td align="right">30</td>
<td align="right">40</td>
<td align="right">42</td>
<td align="right">46</td>
<td align="right">40</td>
<td align="right">31</td>
<td align="right">27</td>
<td align="right">19</td>
<td align="right">2563</td>
</tr>
<tr class="odd">
<td align="right">80.0</td>
<td align="right">58.0</td>
<td align="right">35</td>
<td align="right">28</td>
<td align="right">37</td>
<td align="right">42</td>
<td align="right">46</td>
<td align="right">40</td>
<td align="right">29</td>
<td align="right">25</td>
<td align="right">12</td>
<td align="right">2562</td>
</tr>
<tr class="even">
<td align="right">46.7</td>
<td align="right">82.0</td>
<td align="right">58</td>
<td align="right">35</td>
<td align="right">28</td>
<td align="right">40</td>
<td align="right">46</td>
<td align="right">49</td>
<td align="right">40</td>
<td align="right">29</td>
<td align="right">25</td>
<td align="right">2561</td>
</tr>
<tr class="odd">
<td align="right">52.0</td>
<td align="right">46.7</td>
<td align="right">82</td>
<td align="right">58</td>
<td align="right">35</td>
<td align="right">28</td>
<td align="right">40</td>
<td align="right">41</td>
<td align="right">44</td>
<td align="right">40</td>
<td align="right">29</td>
<td align="right">2560</td>
</tr>
<tr class="even">
<td align="right">52.0</td>
<td align="right">46.7</td>
<td align="right">82</td>
<td align="right">58</td>
<td align="right">35</td>
<td align="right">28</td>
<td align="right">40</td>
<td align="right">41</td>
<td align="right">44</td>
<td align="right">40</td>
<td align="right">29</td>
<td align="right">2559</td>
</tr>
</tbody>
</table>

-----------------------------------

### 结语
此处应该有掌声，哈哈。
目前此处只纳入了几种较为简单的评估方法，更为精细的评估如结合土地回归模型或个体出行模式，往往会让模型变得更为复杂，后续若有时间，我会将结合个体出行模式的函数整理出来，进一步丰富该处内容。
如果你对于这个模型有啥建议，请在[此处](https://github.com/Spatial-R/Environmental-Exposure-Estimate/issues)提交你的意见，非常感谢。

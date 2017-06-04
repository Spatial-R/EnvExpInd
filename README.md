# Environmental-Exposure-Estimation
**EnvExpInd** is a package to estimate the environmental exposure on the individual level. If you have found any bugs, please set up an issue [here](https://github.com/Spatial-R/Environmental-Exposure-Estimate/issues)

### 数据类型

若需通过环境常规监测站点数据计算个体环境暴露量，则至少需要监测站点环境数据和样本个体信息，以空气污染为例，一般需要**监测站点信息**、**空气污染数据**、**个体信息**

-   监测站点信息：包括**监测站点名称**和监测站点**详细地址信息**。

-   空气污染数据：包括**监测站点名称**、**监测时间**、**污染物浓度数据**。

-   个体信息：包括个体**详细地址信息**和**个体时间信息**(如发病时间、死亡时间、怀孕时间等)。

### 整体思路

1.  根据监测站点信息地址信息和个体详细地址信息获取其对应的经纬度信息。

2.  根据个体经纬度信息，获取每个个体对应的监测站点编号或浓度差值后的经纬度点。

3.  根据每个个体的时间信息和需评估的时长获得每个个体的评估时长。

4.  根据第二步和第三步获取的信息，获得每个个体的污染物暴露量。

#### 安装

程序包现如今在github上，所以需要用devtools::install\_github进行安装

    devtools::install_github("Spatial-R/EnvExpInd")

### 第一步：读取相关数据

安装好程序包后，可以直接用该包自带的'envid'数据集进行测试，其包含三类数据，分别为空气污染数据(pollutant.csv)、监测站点数据(site.csv)和样本数据(patient.csv)。为保证后续数据处理过程能顺利进行，需要空气污染数据库和样本数据库中的日期变量转换成日期格式(默认为字符串)。

    data("envind")
    individual_data_tem$date <- as.Date(individual_data_tem$date);
    pollutant_data$date <- as.Date(pollutant_data$date)

样本数据集individual\_data\_tem包含**病例编号**(id,编号不重复)、**病例日期**（date,格式为2014-10-20）和详细地址信息(address,
尽可能详细)。具体格式如下：

<table>
<thead>
<tr class="header">
<th align="right">X</th>
<th align="right">id</th>
<th align="left">date</th>
<th align="left">address</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td align="right">1000</td>
<td align="right">2564</td>
<td align="left">2015-01-05</td>
<td align="left">湖北省武汉市汉阳区界牌中湾</td>
</tr>
<tr class="even">
<td align="right">1001</td>
<td align="right">2563</td>
<td align="left">2015-01-04</td>
<td align="left">湖北省武汉市江汉区满春路</td>
</tr>
<tr class="odd">
<td align="right">1002</td>
<td align="right">2562</td>
<td align="left">2015-01-04</td>
<td align="left">湖北省武汉市硚口区凌霄小巷</td>
</tr>
<tr class="even">
<td align="right">1003</td>
<td align="right">2561</td>
<td align="left">2015-01-03</td>
<td align="left">湖北省武汉市江岸区淌湖二村</td>
</tr>
<tr class="odd">
<td align="right">1004</td>
<td align="right">2560</td>
<td align="left">2015-01-02</td>
<td align="left">湖北省武汉市青山区鄂洲路</td>
</tr>
</tbody>
</table>

空气污染数据集pollutant\_data包含**日期**(变量名称为date,格式为2014-10-20)、**监测站点名称**(变量名称为site.name)和各类**污染物浓度**。具体格式如下：

<table>
<thead>
<tr class="header">
<th align="left">date</th>
<th align="left">site.name</th>
<th align="left">SO2</th>
<th align="left">NO2</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td align="left">2012-12-27</td>
<td align="left">东湖梨园</td>
<td align="left">7</td>
<td align="left">39.2</td>
</tr>
<tr class="even">
<td align="left">2012-12-27</td>
<td align="left">汉阳月湖</td>
<td align="left">16</td>
<td align="left">42.4</td>
</tr>
<tr class="odd">
<td align="left">2012-12-27</td>
<td align="left">汉口花桥</td>
<td align="left">17</td>
<td align="left">44</td>
</tr>
</tbody>
</table>

空气污染数据集常存在缺少数据，如何进行数据填补，可参考如下代码：

监测站点数据集site\_data包含**监测站点名称**(变量名称为site)和**监测站点地址信息**(变量名称为address)。具体格式如下：

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

对于国内用户，可借用百度地图的[API接口](http://lbsyun.baidu.com/index.php?title=webapi/guide/webservice-geocoding)，只需要有详细的地址信息，就可将其转换成经纬度（准确度如何请自行思考）。此处，你需申请一个百度地图API的秘钥，即可用**geo\_latlon**函数加以实现。

    ########## individual_data_tem 含有病例信息，其中通讯地址变量表示地址信息
    ########## site_data 含有站点信息，其中address变量表示地址信息
    ########## notices：秘钥有日使用次数限制，地址信息需尽可能详细

    site_data <- geo_latlon(data = site_data, add_var = "address", api_key = "你的秘钥")
    individual_data_tem <- geo_latlon(data = individual_data_tem, add_var = "address", api_key = "你的秘钥")

#### 第二步：获得个体污染物评估编号

总体而言，有两种方式来获得个体污染物的近似估计值：简单粗暴型和精细型。简单粗暴型是根据个体与各监测站点间距离比较后获得最近的监测站点数据作为该个体暴露评估参考值；精细型则是根据监测站点数据和其他协变量数据(如汽车尾气排放等)进行插值（反距离插值、克里金插值或土地利用回归模型）处理后，个体所在经纬度的插值结果作为个体暴露评估的参考值。此处，简单粗暴型和精细型都给予介绍，但精细型局限于反距离插值和克里金插值。

1.  简单粗暴型（最近监测站点作为参考）

简单粗暴型需要两步，第一步需要解决的一个问题是：个体该以哪个监测站点的数据作为暴露评估的参考点？此问题可用`get_refrence_id_simple`函数（最近距离来筛选参考站点）解决；第二个问题则是在知道参考监测点后如何获得个体不同时间点的暴露值呢？此问题则可用`expoure_estimate_simple`函数来解决。

首先，第一个问题解决示例如下：

    individual_data_tem$refrence_id <- get_refrence_id_simple(individual_data = individual_data_tem, 
                                                          individual_lat = "lat",
                                                          individual_lon ="lon",
                                                          individual_id = "id",
                                                          site_data = site_data,
                                                          site_lat = "lat",
                                                          site_lon = "lon",
                                                          site_id = "site")
    kable(head(individual_data_tem[,-3]))   #### don't show the address

<table>
<thead>
<tr class="header">
<th></th>
<th align="right">id</th>
<th align="left">date</th>
<th align="right">lat</th>
<th align="right">lon</th>
<th align="left">refrence_id</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td>1000</td>
<td align="right">2564</td>
<td align="left">2015/1/5</td>
<td align="right">114.2475</td>
<td align="right">30.51260</td>
<td align="left">汉阳月湖</td>
</tr>
<tr class="even">
<td>1001</td>
<td align="right">2563</td>
<td align="left">2015/1/4</td>
<td align="right">114.2881</td>
<td align="right">30.57810</td>
<td align="left">汉阳月湖</td>
</tr>
<tr class="odd">
<td>1002</td>
<td align="right">2562</td>
<td align="left">2015/1/4</td>
<td align="right">114.2198</td>
<td align="right">30.60389</td>
<td align="left">汉阳月湖</td>
</tr>
<tr class="even">
<td>1003</td>
<td align="right">2561</td>
<td align="left">2015/1/3</td>
<td align="right">114.3103</td>
<td align="right">30.64277</td>
<td align="left">汉口花桥</td>
</tr>
<tr class="odd">
<td>1004</td>
<td align="right">2560</td>
<td align="left">2015/1/2</td>
<td align="right">114.4445</td>
<td align="right">30.63321</td>
<td align="left">青山钢花</td>
</tr>
<tr class="even">
<td>1005</td>
<td align="right">2559</td>
<td align="left">2015/1/2</td>
<td align="right">114.3159</td>
<td align="right">30.53973</td>
<td align="left">武昌紫阳</td>
</tr>
</tbody>
</table>

此处可知，对于编号2564需采用监测点汉阳月湖的空气污染浓度监测数据作为参考来获取暴露值。

在获得参考监测站点后，我们通过`expoure_estimate_simple`来获得个体暴露值，具体示例代码如下：

    pollutant_data_tem$date <- as.Date(pollutant_data_tem$date)
    individual_data_tem$date <- as.Date(individual_data_tem$date)
    exposure.simple <- expoure_estimate_simple(individual_data = individual_data_tem,
                                               individual_id = "id",
                                               refrence_id = "refrence_id",
                                               exposure_date = "date",
                                               pollutant_data = pollutant_data_tem,
                                               pollutant_site = "site.name",
                                               pollutant_date = "date",
                                               pollutant_name = c("PM10","SO2"),
                                               estimate_interval = c(0:1))

    kable(head(exposure.simple$PM10),digits= 1)   #### PM10 estimation

<table>
<thead>
<tr class="header">
<th align="left">id</th>
<th align="left">day.0</th>
<th align="left">day.1</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td align="left">2564</td>
<td align="left">202</td>
<td align="left">206</td>
</tr>
<tr class="even">
<td align="left">2563</td>
<td align="left">206</td>
<td align="left">220</td>
</tr>
<tr class="odd">
<td align="left">2562</td>
<td align="left">206</td>
<td align="left">220</td>
</tr>
<tr class="even">
<td align="left">2561</td>
<td align="left">230</td>
<td align="left">200</td>
</tr>
<tr class="odd">
<td align="left">2560</td>
<td align="left">212</td>
<td align="left">146</td>
</tr>
<tr class="even">
<td align="left">2559</td>
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
</tr>
</thead>
<tbody>
<tr class="odd">
<td align="left">2564</td>
<td align="left">27</td>
<td align="left">47</td>
</tr>
<tr class="even">
<td align="left">2563</td>
<td align="left">47</td>
<td align="left">60</td>
</tr>
<tr class="odd">
<td align="left">2562</td>
<td align="left">47</td>
<td align="left">60</td>
</tr>
<tr class="even">
<td align="left">2561</td>
<td align="left">82</td>
<td align="left">52</td>
</tr>
<tr class="odd">
<td align="left">2560</td>
<td align="left">54</td>
<td align="left">72</td>
</tr>
<tr class="even">
<td align="left">2559</td>
<td align="left">44</td>
<td align="left">52</td>
</tr>
</tbody>
</table>

------------------------------------------------------------------------

1.  精细型

精细型此处只提供两种，一种是反距离插值，一种是克里金插值。这两种类型都需调用**gstat**这个程序包，所以，你懂得：install\_packages("gstat")
反距离插值可用'exposure\_estimate\_idw'函数加以实现，示例如下：

    pollutant_data_tem_idw <- merge(pollutant_data_tem,site_data[,c(1,3,4)],by.x = "site.name",by.y = "site", all.x = T)

    exposure.idw <- exposure_estimate_idw(individual_data = individual_data_tem,
                                          individual_id = "id",
                                          exposure_date ="date",
                                          individual_lat ="lat",
                                          individual_lon ="lon",
                                          pollutant_data = pollutant_data_tem_idw,
                                          pollutant_date = "date",
                                          pollutant_site_lat = "lat",
                                          pollutant_site_lon = "lon",
                                          pollutant_name = c("PM10","SO2"),
                                          estimate_interval = c(0:1))  

   
    kable(head(exposure.idw$PM10),digits = 1)   #### PM10 estimation

<table>
<thead>
<tr class="header">
<th align="right">id</th>
<th align="right">day.0</th>
<th align="right">day.1</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td align="right">2564</td>
<td align="right">196.1</td>
<td align="right">198.6</td>
</tr>
<tr class="even">
<td align="right">2563</td>
<td align="right">220.2</td>
<td align="right">198.6</td>
</tr>
<tr class="odd">
<td align="right">2562</td>
<td align="right">227.0</td>
<td align="right">194.7</td>
</tr>
<tr class="even">
<td align="right">2561</td>
<td align="right">191.0</td>
<td align="right">224.1</td>
</tr>
<tr class="odd">
<td align="right">2560</td>
<td align="right">141.6</td>
<td align="right">186.6</td>
</tr>
<tr class="even">
<td align="right">2559</td>
<td align="right">136.1</td>
<td align="right">176.1</td>
</tr>
</tbody>
</table>

    kable(head(exposure.idw$SO2),digits= 1)   #### SO2 estimation

<table>
<thead>
<tr class="header">
<th align="right">id</th>
<th align="right">day.0</th>
<th align="right">day.1</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td align="right">2564</td>
<td align="right">52.9</td>
<td align="right">33.1</td>
</tr>
<tr class="even">
<td align="right">2563</td>
<td align="right">72.1</td>
<td align="right">53.0</td>
</tr>
<tr class="odd">
<td align="right">2562</td>
<td align="right">73.3</td>
<td align="right">53.2</td>
</tr>
<tr class="even">
<td align="right">2561</td>
<td align="right">50.8</td>
<td align="right">81.0</td>
</tr>
<tr class="odd">
<td align="right">2560</td>
<td align="right">58.7</td>
<td align="right">44.5</td>
</tr>
<tr class="even">
<td align="right">2559</td>
<td align="right">51.9</td>
<td align="right">44.0</td>
</tr>
</tbody>
</table>

克里金插值可用'exposure\_estimate\_krige'加以实现，不过采用克里金插值前，你首先要定义半变异函数。

    example.date <- range(pollutant_data_tem$date)[2]
    test.pollutant <- filter(pollutant_data_tem,date == example.date)[,c(2,5)]
    test.pollutant <- merge(test.pollutant,site_data,by.x = "site.name",by.y = "site")
    coordinates(test.pollutant) = ~lat + lon
    m <- fit.variogram(variogram(PM10~1, test.pollutant), vgm(1, "Sph", 200, 1))

    estimate.krige <- exposure_estimate_krige(individual_data = individual_data_tem,
                                         individual_id = "id",
                                         exposure_date = "date",
                                         individual_lat = "lat",
                                         individual_lon = "lon",
                                         pollutant_data = pollutant_data_tem_idw,
                                         pollutant_date = "date",
                                         pollutant_site_lat = "lat",
                                         pollutant_site_lon = "lon",
                                         pollutant_name = c("PM10","SO2"),
                                         estimate_interval = c(0:1),
                                         krige_model = m,
                                         nmax = 7,
                                         krige_method = "med")


    kable(head(estimate.krige$PM10),digits = 1)   #### PM10 estimation

<table>
<thead>
<tr class="header">
<th align="right">id</th>
<th align="right">day.0</th>
<th align="right">day.1</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td align="right">2564</td>
<td align="right">194</td>
<td align="right">198</td>
</tr>
<tr class="even">
<td align="right">2563</td>
<td align="right">220</td>
<td align="right">198</td>
</tr>
<tr class="odd">
<td align="right">2562</td>
<td align="right">220</td>
<td align="right">194</td>
</tr>
<tr class="even">
<td align="right">2561</td>
<td align="right">192</td>
<td align="right">220</td>
</tr>
<tr class="odd">
<td align="right">2560</td>
<td align="right">136</td>
<td align="right">178</td>
</tr>
<tr class="even">
<td align="right">2559</td>
<td align="right">136</td>
<td align="right">178</td>
</tr>
</tbody>
</table>

    kable(head(estimate.krige$SO2),digits = 1)   #### SO2 estimation

<table>
<thead>
<tr class="header">
<th align="right">id</th>
<th align="right">day.0</th>
<th align="right">day.1</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td align="right">2564</td>
<td align="right">58.0</td>
<td align="right">35.0</td>
</tr>
<tr class="even">
<td align="right">2563</td>
<td align="right">82.0</td>
<td align="right">58.0</td>
</tr>
<tr class="odd">
<td align="right">2562</td>
<td align="right">80.0</td>
<td align="right">58.0</td>
</tr>
<tr class="even">
<td align="right">2561</td>
<td align="right">46.7</td>
<td align="right">82.0</td>
</tr>
<tr class="odd">
<td align="right">2560</td>
<td align="right">52.0</td>
<td align="right">46.7</td>
</tr>
<tr class="even">
<td align="right">2559</td>
<td align="right">52.0</td>
<td align="right">46.7</td>
</tr>
</tbody>
</table>
-----------------------------------------------------------------------------------


若您觉得该包有bug，请在[此处](https://github.com/Spatial-R/Environmental-Exposure-Estimate/issues)提交你的意见，非常感谢。

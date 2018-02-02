# Hadoop全排序中的Sampler采样器

我们已经了解过Partitioner组件的其中一个和全排序相关的实现类----TotalOrderPartitioner。

我们知道，在Hadoop中，最终的处理结果集中的数据，除非就由一个Reduce Task处理，否则结果数据集只是局部有序而非全排序。

这节我们来学习在Hadoop中进行全排序操作中除了TotalOrderPartitioner之外的另一个组件----采样器Sampler。

在新版本的Hadoop中，内置了三个采样器： SplitSampler，RandomSampler和IntervalSampler。这三个采样器都是InputSampler类的静态内部类，并且都实现了InputSampler类的内部接口Sampler，涉及的相关代码如下：

```java
/**
 * Utility for collecting samples and writing a partition file for
 * {@link org.apache.hadoop.mapred.lib.TotalOrderPartitioner}.
 */
public class InputSampler<K,V> implements Tool {
  ...
  /**
   *采样器接口
   */
  public interface Sampler<K,V> {
    /**
     * 从输入数据几种获得一个数据采样的子集，然后通过这些采样数据在Map端由
     * TotalOrderPartitioner对处理数据做hash分组，以保证不同Reduce处理数据的有序性。
     * 该方法的具体采样逻辑由继承类实现。
     * For a given job, collect and return a subset of the keys from the
     * input data.
     */
    K[] getSample(InputFormat<K,V> inf, JobConf job) throws IOException;
  }

  /**
   * 分片数据采样器，即从N个分片中采样，效率最高
   * Samples the first n records from s splits.
   * Inexpensive way to sample random data.
   */
  public static class SplitSampler<K,V> implements Sampler<K,V> {
     ...
  }

  /**
   * 通用的随机数据采样器，按一定的频率对所有数据做随机采样，效率很低
   * Sample from random points in the input.
   * General-purpose sampler. Takes numSamples / maxSplitsSampled inputs from
   * each split.
   */
  public static class RandomSampler<K,V> implements Sampler<K,V> {
    ...
  }

  /**
   * 有固定采样间隔的数据采样器，适合有序的数据集，效率较随机数据采样器要好一些
   * Sample from s splits at regular intervals.
   * Useful for sorted data.
   */
  public static class IntervalSampler<K,V> implements Sampler<K,V> {
     ...
  }
  ...
}
```

从上面的代码及注释中我们可以了解该采样器是如何对数据采样的。对于每一个分区，读取一条记录，将这条记录添加到样本集合中，如果当前样本数大于当前的采样分区所需要的样本数，则停止对这个分区的采样。如此循环遍历完这个分区的所有记录。

## SplitSampler

我们首先着重来看一下SplitSampler采样器是如何对数据采样的，先看其取样处理逻辑代码：

```java
/**
   * Samples the first n records from s splits.
   * Inexpensive way to sample random data.
   */
  public static class SplitSampler<K,V> implements Sampler<K,V> {

    ...

    /**
     * From each split sampled, take the first numSamples / numSplits records.
     */
    @SuppressWarnings("unchecked") // ArrayList::toArray doesn't preserve type
    public K[] getSample(InputFormat<K,V> inf, JobConf job) throws IOException {
      //通过InputFormat组件读取所有的分片信息，之前在InputFormat组件的学习中已学习过
      InputSplit[] splits = inf.getSplits(job, job.getNumMapTasks());
      ArrayList<K> samples = new ArrayList<K>(numSamples);
      //获得采样分区数，在最大采样数最大分区数和总分区数中选择较小的
      int splitsToSample = Math.min(maxSplitsSampled, splits.length);
      //获取采样分区间隔
      int splitStep = splits.length / splitsToSample;
      //计算获取每个分区的采样数
      int samplesPerSplit = numSamples / splitsToSample;
      long records = 0;
      for (int i = 0; i < splitsToSample; ++i) {
        //获取第(i * splitStep)分片的RecordReader对象，并由该对象解析将数据解析成key/value
        RecordReader<K,V> reader = inf.getRecordReader(splits[i * splitStep],
            job, Reporter.NULL);
        K key = reader.createKey();
        V value = reader.createValue();
        while (reader.next(key, value)) {//向采样的空key和value中读入数据
          //将采样的key加入samples数组
          samples.add(key);
          key = reader.createKey();
          ++records;
          if ((i+1) * samplesPerSplit <= records) {//判断是否满足采样数
            break;
          }
        }
        reader.close();
      }
      //返回采样的key的数组，供TotalOrderPartitioner使用
      return (K[])samples.toArray();
    }
  }
```

## RandomSampler

> RandomSampler随机地从输入数据中抽取Key，是一个通用的采样器。RandomSampler类有三个属性：freq（一个Key被选中的概率），numSamples（从所有被选中的分区中获得的总共的样本数目），maxSplitsSampled（需要检查扫描的最大分区数目）。

RandomSampler是一个随机数据采样器，效率最低，其采样过程是这样处理的： 首先通过InputFormat的getSplits方法得到所有的输入分区；然后确定需要抽样扫描的分区数目，取输入分区总数与用户输入的maxSplitsSampled两者的较小的值得到splitsToSample；然后对输入分区数组shuffle排序，打乱其原始顺序；然后循环逐个扫描每个分区中的记录进行采样，循环的条件是当前已经扫描的分区数小于splitsToSample或者当前已经扫描的分区数超过了splitsToSample但是小于输入分区总数并且当前的采样数小于最大采样数numSamples。

每个分区中记录采样的具体过程如下： 从指定分区中取出一条记录，判断得到的随机浮点数是否小于等于采样频率freq，如果大于则放弃这条记录，然后判断当前的采样数是否小于最大采样数，如果小于则这条记录被选中，被放进采样集合中，否则从【0，numSamples】中选择一个随机数，如果这个随机数不等于最大采样数numSamples，则用这条记录替换掉采样集合随机数对应位置的记录，同时采样频率freq减小变为freq*(numSamples-1)/numSamples。然后依次遍历分区中的其它记录。

```java
public K[] getSample(InputFormat<K,V> inf, JobConf job) throws IOException {
  InputSplit[] splits = inf.getSplits(job, job.getNumMapTasks());
  ArrayList<K> samples = new ArrayList<K>(numSamples);
  int splitsToSample = Math.min(maxSplitsSampled, splits.length);

  Random r = new Random();
  long seed = r.nextLong();
  r.setSeed(seed);
  LOG.debug("seed: " + seed);
  // shuffle splits
  for (int i = 0; i < splits.length; ++i) {
    InputSplit tmp = splits[i];
    int j = r.nextInt(splits.length);
    splits[i] = splits[j];
    splits[j] = tmp;
  }
  // our target rate is in terms of the maximum number of sample splits,
  // but we accept the possibility of sampling additional splits to hit
  // the target sample keyset
  for (int i = 0; i < splitsToSample ||
                 (i < splits.length && samples.size() < numSamples); ++i) {
    RecordReader<K,V> reader = inf.getRecordReader(splits[i], job,
        Reporter.NULL);
    K key = reader.createKey();
    V value = reader.createValue();
    while (reader.next(key, value)) {
      if (r.nextDouble() <= freq) {
        if (samples.size() < numSamples) {
          samples.add(key);
        } else {
          // When exceeding the maximum number of samples, replace a
          // random element with this one, then adjust the frequency
          // to reflect the possibility of existing elements being
          // pushed out
          int ind = r.nextInt(numSamples);
          if (ind != numSamples) {
            samples.set(ind, key);
          }
          freq *= (numSamples - 1) / (double) numSamples;
        }
        key = reader.createKey();
      }
    }
    reader.close();
  }
  return (K[])samples.toArray();
}
```

## SplitSampler

> 从s个分区中采样前n个记录，是采样随机数据的一种简便方式。SplitSampler类有两个属性：numSamples（最大采样数），maxSplitsSampled（最大分区数）。

首先根据InputFormat得到输入分区数组；然后确定需要采样的分区数splitsToSample为最大分区数和输入分区总数之间的较小值；然后确定对分区采样时的间隔splitStep为输入分区总数除splitsToSample的商；然后确定每个分区的采样数samplesPerSplit为最大采样数除splitsToSample的商。被采样的分区下标为i*splitStep，已经采样的分区数目达到splitsToSample即停止采样。

对于每一个分区，读取一条记录，将这条记录添加到样本集合中，如果当前样本数大于当前的采样分区所需要的样本数，则停止对这个分区的采样。如此循环遍历完这个分区的所有记录。

其getSample方法实现如下：

```java
public K[] getSample(InputFormat<K,V> inf, JobConf job) throws IOException {
  InputSplit[] splits = inf.getSplits(job, job.getNumMapTasks());
  ArrayList<K> samples = new ArrayList<K>(numSamples);
  int splitsToSample = Math.min(maxSplitsSampled, splits.length);
  int splitStep = splits.length / splitsToSample;
  int samplesPerSplit = numSamples / splitsToSample;
  long records = 0;
  for (int i = 0; i < splitsToSample; ++i) {
    RecordReader<K,V> reader = inf.getRecordReader(splits[i * splitStep],
        job, Reporter.NULL);
    K key = reader.createKey();
    V value = reader.createValue();
    while (reader.next(key, value)) {
      samples.add(key);
      key = reader.createKey();
      ++records;
      if ((i+1) * samplesPerSplit <= records) {
        break;
      }
    }
    reader.close();
  }
  return (K[])samples.toArray();
}
```

## IntervalSampler

> 根据一定的间隔从s个分区中采样数据，非常适合对排好序的数据采样。IntervalSampler类有两个属性：freq（哪一条记录被选中的概率），maxSplitsSampled（采样的最大分区数）。

首先根据InputFormat得到输入分区数组；然后确定需要采样的分区数splitsToSample为最大分区数和输入分区总数之间的较小值；然后确定对分区采样时的间隔splitStep为输入分区总数除splitsToSample的商。被采样的分区下标为i*splitStep，已经采样的分区数目达到splitsToSample即停止采样。

对于每一个分区，读取一条记录，如果当前样本数与已经读取的记录数的比值小于freq，则将这条记录添加到样本集合，否则读取下一条记录。这样依次循环遍历完这个分区的所有记录。

再来看一下IntervalSampler采样器是如何来对数据采样的：

```java
public static class IntervalSampler<K,V> implements Sampler<K,V> {
    ...
    /**
     * 根据一定的间隔从s个分区中采样数据，非常适合对排好序的数据采样
     * For each split sampled, emit when the ratio of the number of records
     * retained to the total record count is less than the specified
     * frequency.
     */
    @SuppressWarnings("unchecked") // ArrayList::toArray doesn't preserve type
    public K[] getSample(InputFormat<K,V> inf, JobConf job) throws IOException {
      //通过InputFormat组件读取所有的分片信息
      InputSplit[] splits = inf.getSplits(job, job.getNumMapTasks());
      ArrayList<K> samples = new ArrayList<K>();
      //获得采样分区数，在最大采样数最大分区数和总分区数中选择较小的
      int splitsToSample = Math.min(maxSplitsSampled, splits.length);
      //获取采样分区间隔
      int splitStep = splits.length / splitsToSample;
      long records = 0;
      long kept = 0;
      for (int i = 0; i < splitsToSample; ++i) {
        //获取第(i * splitStep)分片的RecordReader对象，并由该对象解析将数据解析成key/value
        RecordReader<K,V> reader = inf.getRecordReader(splits[i * splitStep],
            job, Reporter.NULL);
        K key = reader.createKey();
        V value = reader.createValue();
        while (reader.next(key, value)) {//向采样的空key和value中读入数据
          ++records;
          if ((double) kept / records < freq) {//判断当前样本数与已经读取的记录数的比值小于freq
            ++kept;
            samples.add(key);
            key = reader.createKey();
          }
        }
        reader.close();
      }
      //返回采样的key的数组，供TotalOrderPartitioner使用
      return (K[])samples.toArray();
    }
  }
```

从上面的代码可以看到，该采样器和SplitSampler采样器很像。对于每一个分区，读取一条记录，如果当前样本数与已经读取的记录数的比值小于freq，则将这条记录添加到样本集合，否则读取下一条记录。这样依次循环遍历完这个分区的所有记录。

下面是几个采样器之间的比较：

类名 | 采样方式 | 构造方法 | 效率 | 特点
-- | :--: | :--: | -- | :--:
SplitSampler<K,V>|对前n个记录进行采样|采样总数，化分数|最高|
RandomSampler<K,V>|遍历所有数据，随机采样|采样频率，采样总数，划分数|最低|
IntervalSampler<K,V>|固定间隔采样|采样总数，化分数|中|对有序的数据十分适用|

> 可以自定义采样器

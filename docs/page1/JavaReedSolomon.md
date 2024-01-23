# JavaReedSolomon

## 基础类

### CodingLoopBase(编码循环基础类)

```java
public abstract class CodingLoopBase implements CodingLoop {

    @Override
    public boolean checkSomeShards(
            byte[][] matrixRows,
            byte[][] inputs, int inputCount, //dataShardCount
            byte[][] toCheck, int checkCount,// parityShardCount
            int offset, int byteCount,
            byte[] tempBuffer) {

        // 检测冗余数据部分的是否为正确的
        byte [] [] table = Galois.MULTIPLICATION_TABLE;
        for (int iByte = offset; iByte < offset + byteCount; iByte++) {
            for (int iOutput = 0; iOutput < checkCount; iOutput++) {
                byte [] matrixRow = matrixRows[iOutput];
                //小优化 和上面的matrixRow一样，简化下面数组访问操作
                byte [] input = inputs[iInput];
                int value = 0;
                for (int iInput = 0; iInput < inputCount; iInput++) {
                    // 有限域中的加法是异或
                    value ^= table[matrixRow[iInput] & 0xFF][input[iByte] & 0xFF];
                }
                if (toCheck[iOutput][iByte] != (byte) value) {
                    return false;
                }
            }
        }
        return true;
    }
}
```

### Galois(有限域)

在有限域中，加减法是异或，乘除法是自己定义的方法



#### generateLogTable(对数表)

```java
public static short [] generateLogTable(int polynomial) {
    	// result中存放的是查询一个值的对数是多少 result[查询的值]= 对数->几次方;以2为底
        short [] result = new short[FIELD_SIZE];
        // -1 means "not set"
        Arrays.fill(result, (short) -1);

        int b = 1;

        for (int log = 0; log < FIELD_SIZE - 1; log++) {
            if (result[b] != -1) {
                throw new RuntimeException("BUG: duplicate logarithm (bad polynomial?)");
            }
            result[b] = (short) log;
            b = (b << 1);
            if (FIELD_SIZE <= b) {
                b = ((b - FIELD_SIZE) ^ polynomial); //这边还是不大懂为什么可以生成不同的b
            }
        }
        return result;
    }
```



#### generateExpTable(幂值表)

```java
public static byte [] generateExpTable(short [] logTable) {
    	// result存放的是查询一个对应对数的幂值的result[查询值]=2^(查询值) 次幂运算
    	//设置两倍的大小，方便乘法查值的时候不用考虑范围
        final byte [] result = new byte [FIELD_SIZE * 2 - 2];
    	// 记录对应的值 可以说是遍历 也可以说是挨个去查询
        for (int i = 1; i < FIELD_SIZE; i++) {
            int log = logTable[i];
            result[log] = (byte) i;
            result[log + FIELD_SIZE - 1] = (byte) i;
        }
        return result;
    }
```



#### allPossiblePolynomials(生成多项式)

通过检测没有异常的去获得生成多项式

```java
final Integer [] polynomials = {
                29, 43, 45, 77, 95, 99, 101, 105, 113,
                135, 141, 169, 195, 207, 231, 245
        };//生成多项式的值通常是经过研究和测试确定的，而不是通过某种公式计算得出的。
public static Integer [] allPossiblePolynomials() {
        List<Integer> result = new ArrayList<>();
        for (int i = 0; i < FIELD_SIZE; i++) {
            try {
                generateLogTable(i);
                result.add(i);
            }
            catch (RuntimeException e) {
                // this one didn't work
            }
        }
        return result.toArray(new Integer[0]);
    }
```



#### MULTIPLICATION_TABLE*(乘法表)

```java
public static byte [] [] MULTIPLICATION_TABLE = generateMultiplicationTable();
public static byte [] [] generateMultiplicationTable() {
        byte [] [] result = new byte [256] [256];
        for (int a = 0; a < FIELD_SIZE; a++) {
            for (int b = 0; b < FIELD_SIZE; b++) {
                result[a][b] = multiply((byte) a, (byte) b);
            }
        }
        return result;
    }
```



#### multiply(乘法)

通过对数加去完成计算，并用查表的方法获得结果

```java
public static byte multiply(byte a, byte b) {
        if (a == 0 || b == 0) {
            return 0;
        }
        else {
            int logA = LOG_TABLE[a & 0xFF];
            int logB = LOG_TABLE[b & 0xFF];
            int logResult = logA + logB;
            return EXP_TABLE[logResult];
        }
    }
```



#### divide(除法)

通过对数减去完成计算，并用查表的方法获得结果

```java
public static byte divide(byte a, byte b) {
        if (a == 0) {
            return 0;
        }
        if (b == 0) {
            // 除数为0的异常
            throw new IllegalArgumentException("Argument 'divisor' is 0");
        }
        int logA = LOG_TABLE[a & 0xFF];
        int logB = LOG_TABLE[b & 0xFF];
        int logResult = logA - logB;
        if (logResult < 0) {
            logResult += 255;
        }
        return EXP_TABLE[logResult];
    }
```



#### exp(幂运算)

```java
public static byte exp(byte a, int n) {
        if (n == 0) {
            return 1;
        }
        else if (a == 0) {
            return 0;
        }
        else {
            //利用对数和查表简化运算
            int logA = LOG_TABLE[a & 0xFF];
            int logResult = logA * n;
            while (255 <= logResult) {
                logResult -= 255;
            }
            return EXP_TABLE[logResult];
        }
    }
```

### Matrix(矩阵)

#### 属性以及基础函数

```java
//矩阵的行
private final int rows;

//矩阵的列
private final int columns;

//存放的数据二维数组，即对应矩阵
private final byte [] [] data;

//初始化构造函数，里面的data设置为0
public Matrix(int initRows, int initColumns);

//初始化data数据
public Matrix(byte [] [] initData);

//返回给定大小的单位矩阵  就是对角线都是1其余为0的矩阵
public static Matrix identity(int size);

//获得列数
public int getColumns();

//获得行数
public int getRows();

//获得对应位置的数据
public byte get(int r, int c);

//设置对应位置的数据
public void set(int r, int c, byte value);

//获得其中一行
public byte [] getRow(int row);

//交换指定的两行
public void swapRows(int r1, int r2);
```



#### 乘法

```java
//当前矩阵在左边，乘上另一个矩阵
public Matrix times(Matrix right) {
    	//判断是否能运算，左边的列数要等于右边的行数
        if (getColumns() != right.getRows()) {
            throw new IllegalArgumentException(
                    "Columns on left (" + getColumns() +") " +
                    "is different than rows on right (" + right.getRows() + ")");
        }
        Matrix result = new Matrix(getRows(), right.getColumns());
        for (int r = 0; r < getRows(); r++) {
            for (int c = 0; c < right.getColumns(); c++) {
                byte value = 0;
                for (int i = 0; i < getColumns(); i++) {
                    //使用有限域的加和成法来进行计算
                    value ^= Galois.multiply(get(r, i), right.get(i, c));
                }
                result.set(r, c, value);
            }
        }
        return result;
    }
```



#### 链接

```java
//返回此矩阵和右侧矩阵的链接
public Matrix augment(Matrix right) {
    	//如果两个矩阵行数不同，无法进行链接
        if (rows != right.rows) {
            throw new IllegalArgumentException("Matrices don't have the same number of rows");
        }
        Matrix result = new Matrix(rows, columns + right.columns);
        for (int r = 0; r < rows; r++) {
            //循环拼接数据
            for (int c = 0; c < columns; c++) {
                result.data[r][c] = data[r][c];
            }
            for (int c = 0; c < right.columns; c++) {
                result.data[r][columns + c] = right.data[r][c];
            }
        }
        return result;
    }
```



#### 提取

```java
//提取从rmin到rmax行数，从cmin到cmax列数的矩阵
public Matrix submatrix(int rmin, int cmin, int rmax, int cmax) {
        Matrix result = new Matrix(rmax - rmin, cmax - cmin);
        for (int r = rmin; r < rmax; r++) {
            for (int c = cmin; c < cmax; c++) {
                result.data[r - rmin][c - cmin] = data[r][c];
            }
        }
        return result;
    }
```



#### 高斯消元法

```java
private void gaussianElimination() {
        // 使得对角线为1，下半部分为0
        for (int r = 0; r < rows; r++) {
            // 如果对角线上的元素为0，找到下面的一行非0的并进行交换
            if (data[r][r] == (byte) 0) {
                for (int rowBelow = r + 1; rowBelow < rows; rowBelow++) {
                    if (data[rowBelow][r] != 0) {
                        swapRows(r, rowBelow);
                        break;
                    }
                }
            }
            // 如果没有找到非0，说明是奇异矩阵，可以有多个解的
            if (data[r][r] == (byte) 0) {
                throw new IllegalArgumentException("Matrix is singular");
            }
            // 归一化
            if (data[r][r] != (byte) 1) {
                // 归一化要相乘的系数，通过有限域的计算获得
                byte scale = Galois.divide((byte) 1, data[r][r]);
                for (int c = 0; c < columns; c++) {
                    //将一整行都乘上这个系数
                    data[r][c] = Galois.multiply(data[r][c], scale);
                }
            }
            // 循环使得对角线下半部分为0，通过减去scale*当前行(归一化处理)
            for (int rowBelow = r + 1; rowBelow < rows; rowBelow++) {
                if (data[rowBelow][r] != (byte) 0) {
                    byte scale = data[rowBelow][r];
                    for (int c = 0; c < columns; c++) {
                        data[rowBelow][c] ^= Galois.multiply(scale, data[r][c]);
                    }
                }
            }
        }

        // 循环使得对角线上半部分为0
        for (int d = 0; d < rows; d++) {
            for (int rowAbove = 0; rowAbove < d; rowAbove++) {
                if (data[rowAbove][d] != (byte) 0) {
                    byte scale = data[rowAbove][d];
                    for (int c = 0; c < columns; c++) {
                        data[rowAbove][c] ^= Galois.multiply(scale, data[d][c]);
                    }

                }
            }
        }
    }
```



#### 求逆

```java
public Matrix invert() {
        // 判断是否为方形矩阵
        if (rows != columns) {
            throw new IllegalArgumentException("Only square matrices can be inverted");
        }

        // 右边拼接一个单位矩阵
        Matrix work = augment(identity(rows));

        // 利用高斯消元法获得逆矩阵
        work.gaussianElimination();

        // 提取逆矩阵
        return work.submatrix(0, rows, columns, columns * 2);
    }
```



#### 范德蒙矩阵

```java
private static Matrix vandermonde(int rows, int cols) {
        Matrix result = new Matrix(rows, cols);
        for (int r = 0; r < rows; r++) {
            for (int c = 0; c < cols; c++) {
                // 用有限域上的计算
                result.set(r, c, Galois.exp((byte) r, c));
            }
        }
        return result;
    }
```



#### 总结

- 一些矩阵的基础方法，什么获得行，获得指定元素，就是你想的那样，通过下标去获取，并没有什么额外的高大上写法
- 注意的点就是为确保计算结果是在一个字节内能表示的，所以要在有限域中进行计算
- 说什么高斯消元法不适合使用与求逆啥的，也不大清楚哈哈，什么LU分解法啥的，以后有兴趣再了解吧哈哈

## 实现类

### ReedSolomon

#### 基础方法

```java
// 获得数据块数
public int getDataShardCount() {
    return dataShardCount;
}
    
// 获得冗余数据块数
public int getParityShardCount() {
    return parityShardCount;
}

//获得总数据块数
public int getTotalShardCount() {
    return totalShardCount;
}
```



#### 构建编码矩阵

```java
private static Matrix buildMatrix(int dataShards, int totalShards) {
        // 从范德蒙矩阵开始。从理论上讲，这个矩阵可以工作，但不具有编码后数据分片不变的属性。
        Matrix vandermonde = vandermonde(totalShards, dataShards);

        // 乘以矩阵最上面平方的逆矩阵。这将使最上面的平方成为单位矩阵，但保留了行的任何平方子集可逆的性质。
        Matrix top = vandermonde.submatrix(0, 0, dataShards, dataShards);
        return vandermonde.times(top.invert());
    }

// 不直接使用单位矩阵与部分范德蒙矩阵拼接的原因
//一个包含单位矩阵和范德蒙德矩阵的组合矩阵。这种矩阵构造方式确实可以保持线性独立性和逆矩阵的性质，但它可能不是最有效的方式，因为在实际应用中，通常更倾向于使用已知的、经过验证的数学结构，如纯 Vandermonde 矩阵，以确保更好的性能和可靠性。
```



#### 构造方法

```java
public ReedSolomon(int dataShardCount, int parityShardCount, CodingLoop codingLoop) {

        // 总共最多可以有256个分片，因为任何更多的分片都会导致Vandermonde矩阵中的重复行，这将导致下面构建的矩阵中的重复行。那么包含重复行的任何子集都是奇异的。
        if (256 < dataShardCount + parityShardCount) {
            throw new IllegalArgumentException("too many shards - max is 256");
        }

    	// 属性初始化
        this.dataShardCount = dataShardCount;
        this.parityShardCount = parityShardCount;
        this.codingLoop = codingLoop;
        this.totalShardCount = dataShardCount + parityShardCount;
    	//获得编码矩阵
        matrix = buildMatrix(dataShardCount, this.totalShardCount);

    	//初始化冗余矩阵
        parityRows = new byte [parityShardCount] [];
        for (int i = 0; i < parityShardCount; i++) {
            parityRows[i] = matrix.getRow(dataShardCount + i);
        }
    }
//parityRows 冗余行矩阵 或 奇偶校验行矩阵
// "奇偶校验行矩阵" 是一种常见的术语，通常用于描述用于奇偶校验编码的数据冗余矩阵。这个术语的名称来源于奇偶校验编码的基本原理，即通过在数据中添加冗余信息（通常是奇偶校验位），以检测和纠正错误。
// 像这里就是添加冗余数据达到检测和纠正错误，所以也可以叫做奇偶校验行矩阵
```



#### 检测输入的数据和大小合不合法

```java
private void checkBuffersAndSizes(byte [] [] shards, int offset, int byteCount) {
        // 传入的shards的块数需要等于总块数
        if (shards.length != totalShardCount) {
            throw new IllegalArgumentException("wrong number of shards: " + shards.length);
        }

        // 所有数据块的大小需要一致
        int shardLength = shards[0].length;
        for (int i = 1; i < shards.length; i++) {
            if (shards[i].length != shardLength) {
                throw new IllegalArgumentException("Shards are different sizes");
            }
        }

        // offset和byteCount必须是非负的，并且适合缓冲区。
        if (offset < 0) {
            throw new IllegalArgumentException("offset is negative: " + offset);
        }
        if (byteCount < 0) {
            throw new IllegalArgumentException("byteCount is negative: " + byteCount);
        }//防止越界
        if (shardLength < offset + byteCount) {
            throw new IllegalArgumentException("buffers to small: " + byteCount + offset);
        }
    }
```



#### 编码冗余矩阵

```java
public void encodeParity(byte[][] shards, int offset, int byteCount) {
        // 先检查参数
        checkBuffersAndSizes(shards, offset, byteCount);

        // 创建冗余矩阵的缓冲区，其实就是本来的
        byte [] [] outputs = new byte [parityShardCount] [];
        System.arraycopy(shards, dataShardCount, outputs, 0, parityShardCount);

        // 调用编码函数
        codingLoop.codeSomeShards(
                parityRows,
                shards, dataShardCount,
                outputs, parityShardCount,
                offset, byteCount);
    }
```

对上面的数组复制做一个补充

```java
public void xxxy() {
        int []arr =new int []{1,2,3,4};
        int []brr = new int[4];

        System.arraycopy(arr, 0, brr, 0, 4);

        brr[2]=8;

        System.out.println(Arrays.toString(arr));
        System.out.println(Arrays.toString(brr));

        int [][] crr =new int[3][3];

        for(int i=0;i<3;i++){
            for(int j=0;j<3;j++){
                crr[i][j]=i*10+j;
            }
        }
        int [][] drr =new int[3][];

        System.arraycopy(crr, 0, drr, 0, 3);
        drr[1][2]=0;
        System.out.println(Arrays.deepToString(crr));
        System.out.println(Arrays.deepToString(drr));

    }
```

运行结果

```java
[1, 2, 3, 4]
[1, 2, 8, 4]
[[0, 1, 2], [10, 11, 0], [20, 21, 22]]
[[0, 1, 2], [10, 11, 0], [20, 21, 22]]
```

- 他这个复制不涉及深层复制
- 就是简单复制一下值，好比对象里有个指针，并不会复制指针所指的对象的值，而是会只复制这个指针，导致两个指针引用的是同一块地址，就是浅拷贝
- 这里是方便后续编码函数对冗余矩阵的赋值，并且还能顺便作用在shards上，不需要返回值



#### 复原数据块

```java
public void decodeMissing(byte [] [] shards,
                              boolean [] shardPresent,
                              final int offset,
                              final int byteCount) {
        // 调用检测方法检测每个矩阵的大小
        checkBuffersAndSizes(shards, offset, byteCount);

        // 如果所有的数据块都存在，则不需要做什么
        int numberPresent = 0;
        for (int i = 0; i < totalShardCount; i++) {
            if (shardPresent[i]) {
                numberPresent += 1;
            }
        }
        if (numberPresent == totalShardCount) {
            return;
        }

        // 如果数据块不足dataShardcount则抛出异常
        if (numberPresent < dataShardCount) {
            throw new IllegalArgumentException("Not enough shards present");
        }
    
    	// 获得剩下来的数据块对应的编码矩阵行
        Matrix subMatrix = new Matrix(dataShardCount, dataShardCount);
    	// 获得前dataShardCount个数据块; 因为只需要dataShardCount个数据块即可还原数据，减少计算
        byte [] [] subShards = new byte [dataShardCount] [];
        {
            int subMatrixRow = 0;

            for (int matrixRow = 0; matrixRow < totalShardCount && subMatrixRow < dataShardCount; matrixRow++) {
                if (shardPresent[matrixRow]) {
                    for (int c = 0; c < dataShardCount; c++) {
                        subMatrix.set(subMatrixRow, c, matrix.get(matrixRow, c));
                    }
                    subShards[subMatrixRow] = shards[matrixRow];
                    subMatrixRow += 1;
                }
            }
        }

        // 将编码矩阵求逆，为后面的复原数据块做准备
        Matrix dataDecodeMatrix = subMatrix.invert();

        // 再生出那些缺失的数据段
        // 只需要传入缺失数据块对应的编码行即可，已有的数据无需再算一遍，减少计算量
    	// 因为是直接= shards[iShard]，所以后面计算出来的output的值可以直接同步到shards上，因为是直接引用对应的空间
        byte [] [] outputs = new byte [parityShardCount] [];
        byte [] [] matrixRows = new byte [parityShardCount] [];
        int outputCount = 0;
        for (int iShard = 0; iShard < dataShardCount; iShard++) {
            if (!shardPresent[iShard]) {
                outputs[outputCount] = shards[iShard];
                matrixRows[outputCount] = dataDecodeMatrix.getRow(iShard);
                outputCount += 1;
            }
        }
    	//做个检测判断，能缩短一定的时间
        if(outputCount != 0) {
            codingLoop.codeSomeShards(
                    matrixRows,
                    subShards, dataShardCount,
                    outputs, outputCount,
                    offset, byteCount);
        }

        // 同样，再生出那些冗余数据段
    	// 一样的只需要传入缺失冗余数据块对应的编码行即可，已有的数据无需再算一遍，减少计算量
    	// 因为是直接= shards[iShard]，所以后面计算出来的output的值可以直接同步到shards上，因为是直接引用对应的空间
        outputCount = 0;
        for (int iShard = dataShardCount; iShard < totalShardCount; iShard++) {
            if (!shardPresent[iShard]) {
                outputs[outputCount] = shards[iShard];
                //这边就是对应冗余数据块对应的冗余编码矩阵的行
                matrixRows[outputCount] = parityRows[iShard - dataShardCount];
                outputCount += 1;
            }
        }
    	//做个检测判断，能缩短一定的时间
        if(outputCount != 0) {
            codingLoop.codeSomeShards(
                    matrixRows,
                    shards, dataShardCount,
                    outputs, outputCount,
                    offset, byteCount);
        }
    }
```



### InputOutputByteTableCodingLoop

#### 对数据块编码(矩阵相乘)

```java
// 与其说是对数据块编码，不如说是matrixRows和inputs两个矩阵再有限域上的相乘，最后的结果赋值到outputs上
// 在编码和解码都可以用到
public void codeSomeShards(
            byte[][] matrixRows,
            byte[][] inputs, int inputCount,
            byte[][] outputs, int outputCount,
            int offset, int byteCount) {

        final byte [] [] table = Galois.MULTIPLICATION_TABLE;

    	//用于创建一个局部作用域（block），这个作用域可以用来限定变量的作用范围。
        {
            //对输出数据块进行初始化赋值，减少异或次数，提高速度
            final int iInput = 0;
            final byte[] inputShard = inputs[iInput];
            for (int iOutput = 0; iOutput < outputCount; iOutput++) {
                final byte[] outputShard = outputs[iOutput];
                final byte[] matrixRow = matrixRows[iOutput];
                final byte[] multTableRow = table[matrixRow[iInput] & 0xFF];
                for (int iByte = offset; iByte  < offset + byteCount; iByte++) {
                    outputShard[iByte] = multTableRow[inputShard[iByte] & 0xFF];
                }
            }
        }

        for (int iInput = 1; iInput < inputCount; iInput++) {
            final byte[] inputShard = inputs[iInput];
            for (int iOutput = 0; iOutput < outputCount; iOutput++) {
                final byte[] outputShard = outputs[iOutput];
                final byte[] matrixRow = matrixRows[iOutput];
                final byte[] multTableRow = table[matrixRow[iInput] & 0xFF];
                for (int iByte = offset; iByte < offset + byteCount; iByte++) {
                    outputShard[iByte] ^= multTableRow[inputShard[iByte] & 0xFF];
                }
            }
        }
    }
// 第一个部分（iInput = 0）处理的是一个特殊情况，其中 iInput 等于零，即处理输入的第一个数据块。这个特殊情况的优化是因为在进行异或操作时，outputShard[iByte] 的初始值为零，所以无需执行异或操作，可以直接用 multTableRow[inputShard[iByte] & 0xFF] 的值赋给 outputShard[iByte]，这样可以减少循环的迭代次数和内存访问。

// 第二个部分（iInput > 0）处理的是其他输入数据块，因为它们不再具有初始值为零的特性，所以需要执行异或操作以累积结果。
```

![1697944017031](C:\Users\86189\AppData\Roaming\Typora\typora-user-images\1697944017031.png)

### ByteInputOutputTableCodingLoop

```java
public void codeSomeShards(
            byte[][] matrixRows,
            byte[][] inputs, int inputCount,
            byte[][] outputs, int outputCount,
            int offset, int byteCount) {

        byte [] [] table = Galois.MULTIPLICATION_TABLE;
        for (int iByte = offset; iByte < offset + byteCount; iByte++) {
            for (int iOutput = 0; iOutput < outputCount; iOutput++) {
                byte [] matrixRow = matrixRows[iOutput];
                int value = 0;
                for (int iInput = 0; iInput < inputCount; iInput++) {
                    value ^= table[matrixRow[iInput] & 0xFF][inputs[iInput][iByte] & 0xFF];
                }
                outputs[iOutput][iByte] = (byte) value;
            }
        }
    }
```

- 这个编码方式比iob慢，因为是以遍历byte为外层循环，因为大部分情况下byteCount数量级很大，所以对于内部临时变量的创建和销毁的次数增加，运行速率相应的减慢

  

### OutputInputByteTableCodingLoop

```java
public void codeSomeShards(
            byte[][] matrixRows,
            byte[][] inputs, int inputCount,
            byte[][] outputs, int outputCount,
            int offset, int byteCount) {

        final byte [] [] table = Galois.MULTIPLICATION_TABLE;
        for (int iOutput = 0; iOutput < outputCount; iOutput++) {
            final byte [] outputShard = outputs[iOutput];
            final byte[] matrixRow = matrixRows[iOutput];
            {
                final int iInput = 0;
                final byte [] inputShard = inputs[iInput];
                final byte [] multTableRow = table[matrixRow[iInput] & 0xFF];
                for (int iByte = offset; iByte < offset + byteCount; iByte++) {
                    outputShard[iByte] = multTableRow[inputShard[iByte] & 0xFF];
                }
            }
            for (int iInput = 1; iInput < inputCount; iInput++) {
                final byte [] inputShard = inputs[iInput];
                final byte [] multTableRow = table[matrixRow[iInput] & 0xFF];
                for (int iByte = offset; iByte < offset + byteCount; iByte++) {
                    outputShard[iByte] ^= multTableRow[inputShard[iByte] & 0xFF];
                }
            }
        }
    }
```


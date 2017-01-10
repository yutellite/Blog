#container_of

>*include\<linux\/kernel.h\>

###原定义
```
#ifndef offsetof
#define offsetof(type,member) ((size_t)&((type*)0)->member)
#endif
```

```
#ifndef container_of
#define container_of(ptr,type,member) ({\
    const typeof(((type*)0)->member)* __mptr = (ptr);\
    (type*)((char*)__mptr - offsetof(type,member));})
#endif

```

###解释
typeof为gnu对c的扩展关键词，

###例子
```
typedef struct rb_tree_node
{
    int data;
    color_t color;//1-red,0-black
    struct rb_tree_node *left;
    struct rb_tree_node *right;
    struct rb_tree_node *parent;
}rb_tree_node;

rb_tree_node *rb=(rb_tree_node*)malloc(sizeof(rb_tree_node));

root=bst_insert(root, rb);

root->left = (rb_tree_node*)malloc(sizeof(rb_tree_node));
```
现在如果给出了root->left的地址，怎么获取root的地址？
```
rb_tree_node* b=container_of(\&root->left,rb_tree_node,left);
```

###简单构造了两个结点

```
rb_tree_node *rb=(rb_tree_node*)malloc(sizeof(rb_tree_node));
...
root=bst_insert(root, rb);
...
root->left = (rb_tree_node*)malloc(sizeof(rb_tree_node));
...
```

###调用

```
rb_tree_node* b=container_of(&root->left,rb_tree_node,left);
typeof(((rb_tree_node*)0)->left) *tem= &root->left;
rb_tree_node* temp=(rb_tree_node*)((char*)tem - offsetof(rb_tree_node,left));
i=offsetof(rb_tree_node,left);
```
###调试

```
Breakpoint 1, main (argc=1, argv=0x7fffffffde88) at rb_tree.c:117
117         typeof(i) c=0;
(gdb) n
119         rb_tree_node *rb=(rb_tree_node*)malloc(sizeof(rb_tree_node));
(gdb)
120         if(rb==NULL)
(gdb)
125         rb->data=1;
(gdb)
126         root=bst_insert(root, rb);
(gdb)
127         root->left = (rb_tree_node*)malloc(sizeof(rb_tree_node));
(gdb)
128         root->left->data=2;
(gdb)
129         rb_tree_node* b=container_of(&root->left,rb_tree_node,left);
(gdb)
130         typeof(((rb_tree_node*)0)->left) *tem= &root->left;
(gdb) p root
$1 = (rb_tree_node *) 0x602010
(gdb) p b
$2 = (rb_tree_node *) 0x602010
（gdb）
131         rb_tree_node* temp=(rb_tree_node*)((char*)tem - offsetof(rb_tree_node,left));
(gdb) p tem
$4 = (struct rb_tree_node **) 0x602018
(gdb) n
133         i=offsetof(rb_tree_node,left);
(gdb) n
135     }(gdb) p temp
$5 = (rb_tree_node *) 0x602010
(gdb) p tem
$6 = (struct rb_tree_node **) 0x602018
(gdb) p i
$7 = 8
(gdb)
```
结果显而易见，通过tem的地址（即root->left成员的地址），container_of(&root->left,rb_tree_node,left);找到了其parent结构体的首地址。

###3 原理解释

####3.1 offsetof

```
define offsetof(type,member) ((size_t)&((type*)0)->member)
offsetof成功获取到member成员的相对偏移。
-bash代码
(gdb) p ((size_t)&((rb_tree_node*)0)->left)
$1 = 8
```

```
((size_t)&((type*)0)->member)
2
1                           0        -->0
3
2            (rb_tree_node*)0        -->告诉编译器0地址指向结构体rb_tree_node
4
3          &((rb_tree_node*)0)->left)-->取0地址结构体left成员地址，
5
(gdb)   p (&((rb_tree_node*)0)->left)
6
$4 = (struct rb_tree_node **) 0x8
7
 4 ((size_t)&((rb_tree_node*)0)->left)-->将地址转换为unsigned int，得到偏移量
8
(gdb) p ((size_t)&((rb_tree_node*)0)->left)
9
$3 = 8
```
####3.2 typeof
typeof为gnu扩展c的关键词，用以获取其类型，具体用法和实现原理估计和sizeof类似，再编译的时候，通过具体的符号表可以得知其类型。

####3.3 container_of

```
#define container_of(ptr,type,member) ({\
    const typeof(((type*)0)->member)* __mptr = (ptr);\
(type*)((char*)__mptr - offsetof(type,member));})
```
ptr为成员的实际地址，type为成员parent结构体类型，member为成员在结构体中的声明名称。
如实例中，ptr为&root->left, type为rb_tree_node， member为left;

因为地址是向上递增的，所以用member成员的地址减去其偏移即是parent结构体的首地址。

注意看：


```
(type*)((char*)__mptr - offsetof(type,member))
```
其实经过该处理已经能获取到其首地址，为什么还要申请一个临时中间变量

```
const typeof(((type*)0)->member)* __mptr = (ptr);
```
注意看区别：
1、去掉该临时变量

宏定义改为
```
 (type*)((char*)ptr - offsetof(type,member));
.....
```
随便用int去找left的结构体地址
```
int i;
rb_tree_node* b=container_of(&i,rb_tree_node,left);
```
编译：

```
<20 linux6 [ywx] :/onip/ywx/gtest/googletest-master/googletest/usr/red_black_tree/rb_tree>gcc -o rb_tree rb_tree.c -g
```
编译不会报任何错误

####3.4 加上该临时变量

```
#define container_of(ptr,type,member) ({\
    const typeof(((type*)0)->member)* __mptr = (ptr);\
(type*)((char*)__mptr - offsetof(type,member));})
....
.....
随便用int去找left的结构体地址
int i;
rb_tree_node* b=container_of(&i,rb_tree_node,left);
```
编译：

```
<21 linux6 [ywx] :/onip/ywx/gtest/googletest-master/googletest/usr/red_black_tree/rb_tree>gcc -o rb_tree rb_tree.c -g
rb_tree.c: In function 'main':
rb_tree.c:130: warning: initialization from incompatible pointer type
```
所以说，该行主要目的是解决了宏定义无法校验参数类型的问题，赋值给临时变量，能够在编译的时候检测到参数类型不匹配。
 

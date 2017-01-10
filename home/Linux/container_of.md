#container_of

>*include<linux/kernel.h>

##原定义
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

##解释
typeof为gnu对c的扩展关键词，

##例子
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
rb_tree_node* b=container_of(root->left,rb_tree_node,left);
```

// RUN: %clang_cc1 -triple x86_64-apple-darwin10 -emit-llvm -fexceptions -o - %s | FileCheck %s
// rdar://8409336

struct TFENode {
void GetURL() const;
};

@interface TNodeIconAndNameCell
- (const TFENode&) node;
@end

@implementation TNodeIconAndNameCell     
- (const TFENode&) node {
// CHECK: call %struct.TFENode* bitcast (i8* (i8*, i8*, ...)* @objc_msgSend
// CHECK-NEXT: call void @_ZNK7TFENode6GetURLEv(%struct.TFENode* %{{.*}})
	self.node.GetURL();
}	// expected-warning {{control reaches end of non-void function}}
@end

// rdar://8437240
struct X {
  int x;
};

void f0(const X &parent);
@interface A
- (const X&) target;
@end
void f1(A *a) {
// CHECK: [[PRP:%.*]] = call %struct.X* bitcast (i8* (i8*, i8*, ...)* @objc_msgSend
// CHECK-NEXT:call void @_Z2f0RK1X(%struct.X* [[PRP]])
  f0(a.target);

// CHECK: [[MSG:%.*]] = call %struct.X* bitcast (i8* (i8*, i8*, ...)* @objc_msgSend
// CHECK-NEXT:call void @_Z2f0RK1X(%struct.X* [[MSG]])
  f0([a target]);
}

@interface Test2
@property (readonly) int myProperty;
- (int) myProperty;
- (double) myGetter;
@end
void test2() {
    Test2 *obj;
    (void) obj.myProperty; 
    (void) obj.myGetter; 
    static_cast<void>(obj.myProperty);
    static_cast<void>(obj.myGetter);
    void(obj.myProperty);
    void(obj.myGetter);
}
// CHECK: define void @_Z5test2v()
// CHECK: call i32 bitcast
// CHECK: call double bitcast
// CHECK: call i32 bitcast
// CHECK: call double bitcast
// CHECK: call i32 bitcast
// CHECK: call double bitcast

// PR8751
int test3(Test2 *obj) { return obj.myProperty; }

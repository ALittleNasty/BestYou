//
//  ViewController.m
//  BestYou
//
//  Created by 胡阳 on 2020/4/30.
//  Copyright © 2020 胡阳. All rights reserved.
//

#import "ViewController.h"
#import "CustomImageFilterVC.h"
#import "GPUStillImageVC.h"
#import "GPUVideoCameraVC.h"
#import "GPUTakePhotoVC.h"

#import <Masonry/Masonry.h>
#import <TZImagePickerController/TZImagePickerController.h>

static NSString *const kBYListCellID = @"kBYListCellId";

@interface ViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, copy) NSArray *items;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    _items = @[@"自定义滤镜", @"GPUImage 图片滤镜", @"GPUImage 拍照", @"GPUImage 录像"];
    [self setupTableView];
}

- (void)setupTableView
{
    _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_tableView];
    [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:kBYListCellID];
}

#pragma mark - UITableViewDelegate & UITableViewDataSource

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 55.f;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kBYListCellID forIndexPath:indexPath];
    
    cell.textLabel.textAlignment = NSTextAlignmentCenter;
    cell.textLabel.font = [UIFont boldSystemFontOfSize:16];
    cell.textLabel.textColor = [UIColor blackColor];
    cell.textLabel.text = _items[indexPath.row];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0 || indexPath.row == 1) {
        [self selectImageAtIndex:indexPath.row];
    } else if (indexPath.row == 2) {
        GPUTakePhotoVC *vc = [[GPUTakePhotoVC alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
    } else if (indexPath.row == 3) {
        GPUVideoCameraVC *vc = [[GPUVideoCameraVC alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)selectImageAtIndex:(NSInteger)index
{
    TZImagePickerController *imagePickerVc = [[TZImagePickerController alloc] initWithMaxImagesCount:1 delegate:nil];
    [imagePickerVc setDidFinishPickingPhotosHandle:^(NSArray<UIImage *> *photos, NSArray *assets, BOOL isSelectOriginalPhoto) {
       
        if (index == 0) {
            CustomImageFilterVC *vc = [[CustomImageFilterVC alloc] init];
            vc.image = photos.firstObject;
            [self.navigationController pushViewController:vc animated:YES];
        } else if (index == 1) {
            GPUStillImageVC *vc = [[GPUStillImageVC alloc] init];
            vc.image = photos.firstObject;
            [self.navigationController pushViewController:vc animated:YES];
        }
    }];
    [self presentViewController:imagePickerVc animated:YES completion:nil];
}
@end

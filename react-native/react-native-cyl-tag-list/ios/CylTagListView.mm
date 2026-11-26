#import "CylTagListView.h"

#import <react/renderer/components/CylTagListViewSpec/ComponentDescriptors.h>
#import <react/renderer/components/CylTagListViewSpec/EventEmitters.h>
#import <react/renderer/components/CylTagListViewSpec/Props.h>
#import <react/renderer/components/CylTagListViewSpec/RCTComponentViewHelpers.h>

#if __has_include(<CylTagList/CylTagList-Swift.h>)
#import <CylTagList/CylTagList-Swift.h>
#else
#import "CylTagList-Swift.h"
#endif

using namespace facebook::react;

@interface CylTagListView () <RCTCylTagListViewViewProtocol>
@end

@implementation CylTagListView {
  CylTagListBridge *_view;
}

+ (ComponentDescriptorProvider)componentDescriptorProvider
{
  return concreteComponentDescriptorProvider<CylTagListViewComponentDescriptor>();
}

- (instancetype)initWithFrame:(CGRect)frame
{
  if (self = [super initWithFrame:frame]) {
    static const auto defaultProps = std::make_shared<const CylTagListViewProps>();
    _props = defaultProps;
    _view = [[CylTagListBridge alloc] init];
    __weak __typeof(self) weakSelf = self;
    _view.onTap = ^(NSDictionary<NSString *, id> *tag) {
      auto emitter = [weakSelf emitter];
      if (emitter) {
        emitter->onTagTap(CylTagListViewEventEmitter::OnTagTap{
            [tag[@"section"] intValue], [tag[@"item"] intValue], std::string([tag[@"title"] UTF8String])});
      }
    };
    _view.onLongPress = ^(NSDictionary<NSString *, id> *tag) {
      auto emitter = [weakSelf emitter];
      if (emitter) {
        emitter->onTagLongPress(CylTagListViewEventEmitter::OnTagLongPress{
            [tag[@"section"] intValue], [tag[@"item"] intValue], std::string([tag[@"title"] UTF8String])});
      }
    };
    _view.onSelection = ^(NSArray<NSDictionary<NSString *, id> *> *items) {
      auto emitter = [weakSelf emitter];
      if (emitter) {
        NSData *data = [NSJSONSerialization dataWithJSONObject:items options:0 error:nil];
        NSString *json = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        emitter->onSelectionChange(CylTagListViewEventEmitter::OnSelectionChange{std::string(json.UTF8String)});
      }
    };
    _view.onContentHeight = ^(double height) {
      auto emitter = [weakSelf emitter];
      if (emitter) {
        emitter->onContentHeightChange(CylTagListViewEventEmitter::OnContentHeightChange{height});
      }
    };
    self.contentView = _view;
  }
  return self;
}

- (std::shared_ptr<const CylTagListViewEventEmitter>)emitter
{
  return std::static_pointer_cast<const CylTagListViewEventEmitter>(_eventEmitter);
}

- (void)updateProps:(Props::Shared const &)props oldProps:(Props::Shared const &)oldProps
{
  const auto &newViewProps = *std::static_pointer_cast<CylTagListViewProps const>(props);
  [_view setConfigurationJSON:[NSString stringWithUTF8String:newViewProps.configuration.c_str()]];
  [_view setAnimationSpeed:newViewProps.animationSpeed];
  [_view setAnimationLoops:newViewProps.animationLoops];
  [super updateProps:props oldProps:oldProps];
}

- (void)updateEventEmitter:(EventEmitter::Shared const &)eventEmitter
{
  [super updateEventEmitter:eventEmitter];
  // The first layout can come before the event emitter: its height event was dropped, so send it again.
  [_view resendContentHeight];
}

- (void)handleCommand:(const NSString *)commandName args:(const NSArray *)args
{
  RCTCylTagListViewHandleCommand(self, commandName, args);
}

- (void)playAll
{
  [_view playAll];
}

@end

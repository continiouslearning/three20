//
// Copyright 2009-2010 Facebook
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

#import "Three20/TTAlertViewController.h"

#import "Three20/TTAlertViewControllerDelegate.h"
#import "Three20/TTAlertView.h"

#import "Three20/TTGlobalCore.h"

#import "Three20/TTNavigator.h"

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation TTAlertViewController

@synthesize delegate = _delegate, userInfo = _userInfo;

///////////////////////////////////////////////////////////////////////////////////////////////////
// NSObject


- (id)initWithNibName:(NSString *)nibName bundle:(NSBundle *)bundle {
  if (self = [super initWithNibName:nibName bundle:bundle]) {
    _userInfo = nil;
    _delegate = nil;
    _URLs = [[NSMutableArray alloc] init];
  }

  return self;
}

- (id)initWithTitle:(NSString*)title message:(NSString*)message delegate:(id)delegate {
  if (self = [self initWithNibName:nil bundle:nil]) {
    _delegate = delegate;
    if (title) {
      self.alertView.title = title;
    }
    if (message) {
      self.alertView.message = message;
    }
  }
  return self;
}


- (id)initWithTitle:(NSString*)title message:(NSString*)message {
  return [self initWithTitle:title message:message delegate:nil];
}

- (id)init {
  return [self initWithTitle:nil message:nil delegate:nil];
}
- (void)dealloc {
  [(UIAlertView*)self.view setDelegate:nil];
  TT_RELEASE_SAFELY(_URLs);
  TT_RELEASE_SAFELY(_userInfo);
  [super dealloc];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// UIViewController

- (void)loadView {
  TTAlertView* alertView = [[[TTAlertView alloc] initWithTitle:nil message:nil delegate:self
                                                 cancelButtonTitle:nil
                                                 otherButtonTitles:nil] autorelease];
  alertView.popupViewController = self;
  self.view = alertView;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// UTViewController (TTCategory)

- (BOOL)persistView:(NSMutableDictionary*)state {
  return NO;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// TTPopupViewController

- (void)showInView:(UIView*)view animated:(BOOL)animated {
  [self viewWillAppear:animated];
  [self.alertView show];
  [self viewDidAppear:animated];
}

- (void)dismissPopupViewControllerAnimated:(BOOL)animated {
  [self viewWillDisappear:animated];
  [self.alertView dismissWithClickedButtonIndex:self.alertView.cancelButtonIndex animated:animated];
  [self viewDidDisappear:animated];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// UIAlertviewDelegate

- (void)alertView:(UIAlertView*)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
  if ([_delegate respondsToSelector:@selector(alertView:clickedButtonAtIndex:)]) {
    [_delegate alertView:alertView clickedButtonAtIndex:buttonIndex];
  }
}

- (void)alertViewCancel:(UIAlertView*)alertView {
  if ([_delegate respondsToSelector:@selector(alertViewCancel:)]) {
    [_delegate alertViewCancel:alertView];
  }
}

- (void)willPresentAlertView:(UIAlertView*)alertView {
  if ([_delegate respondsToSelector:@selector(willPresentAlertView:)]) {
    [_delegate willPresentAlertView:alertView];
  }
}

- (void)didPresentAlertView:(UIAlertView*)alertView {
  if ([_delegate respondsToSelector:@selector(didPresentAlertView:)]) {
    [_delegate didPresentAlertView:alertView];
  }
}

- (void)alertView:(UIAlertView*)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex {
  if ([_delegate respondsToSelector:@selector(alertView:willDismissWithButtonIndex:)]) {
    [_delegate alertView:alertView willDismissWithButtonIndex:buttonIndex];
  }
}

- (void)alertView:(UIAlertView*)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
  NSString* URL = [self buttonURLAtIndex:buttonIndex];
  BOOL canOpenURL = YES;
  if ([_delegate respondsToSelector:@selector(alertViewController:didDismissWithButtonIndex:URL:)]) {
    canOpenURL = [_delegate alertViewController:self didDismissWithButtonIndex:buttonIndex URL:URL];
  }
  if (URL && canOpenURL) {
    TTOpenURL(URL);
  }
  if ([_delegate respondsToSelector:@selector(alertView:didDismissWithButtonIndex:)]) {
    [_delegate alertView:alertView didDismissWithButtonIndex:buttonIndex];
  }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// public

- (UIAlertView*)alertView {
  return (UIAlertView*)self.view;
}

- (NSInteger)addButtonWithTitle:(NSString*)title URL:(NSString*)URL {
  if (URL) {
    [_URLs addObject:URL];
  } else {
    [_URLs addObject:[NSNull null]];
  }
  return [self.alertView addButtonWithTitle:title];
}

- (NSInteger)addCancelButtonWithTitle:(NSString*)title URL:(NSString*)URL {
  self.alertView.cancelButtonIndex = [self addButtonWithTitle:title URL:URL];
  return self.alertView.cancelButtonIndex;
}

- (NSString*)buttonURLAtIndex:(NSInteger)index {
  id URL = [_URLs objectAtIndex:index];
  return URL != [NSNull null] ? URL : nil;
}

@end

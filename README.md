# CLTokenInputView

![Image](http://cl.ly/image/1y3Q0u0q1N3H/iOS%20Simulator%20Screen%20Shot%20Jan%2028,%202015,%204.30.15%20PM.png)
[![Screencap GFY](http://zippy.gfycat.com/ImpressiveRapidGelding.gif)](http://gfycat.com/ImpressiveRapidGelding)


## About

`CLTokenInputView` is an almost pixel perfect replica of the input portion iOS's native contacts picker, used in Mail.app and Messages.app when composing a new message.

Check out the sample view controller which uses CLTokenInputView to see how to incorporate it into your UI. We use this in our apps at [Cluster Labs, Inc.](https://cluster.co).

Check out [a Swift port of this library](https://github.com/rlaferla/CLTokenInputView-Swift) by [@rlaferla](https://github.com/rlaferla). 

### Note 
It ***does not*** provide the autocomplete drop down and matching; you must provide that yourself, so that `CLTokenInputView` can remain very generic and flexible. You can copy what the sample app is doing to show an autocompleting table view and maintain a list of the selected "tokens".

## Usage

To run the example project, clone the repo, and open the Xcode project. You should use this on iOS 7 and up.

To use this in your code, you should add an instance of `CLTokenInputView` to your view hierarchy. Typically it should be anchored to the top of your UI and to the sides. Using Autolayout `CLTokenInputView` can grow by itself, but if you need to control it manually, you can use the delegate.

You should implement:

```objc
- (void)tokenInputView:(CLTokenInputView *)view didChangeText:(NSString *)text 
{
	// Update your autocompletion table results with the text
}
```

When the user taps on one of your autocomplete items, you should call: `-addToken:` on token input view. Example:

```objc
NSString *name = self.filteredNames[indexPath.row];
CLToken *token = [[CLToken alloc] initWithDisplayText:name context:nil];
[self.tokenInputView addToken:token];
```

Be sure to listen for:

```objc
- (void)tokenInputView:(CLTokenInputView *)view didAddToken:(CLToken *)token;
- (void)tokenInputView:(CLTokenInputView *)view didRemoveToken:(CLToken *)token;
```
...and update your local data model of selected items.

Lastly, you can implement:

```objc
- (CLToken *)tokenInputView:(CLTokenInputView *)view tokenForText:(NSString *)text 
{
	// Return a CLToken instance that matches the text that has been entered.
	// Return nil if nothing matches
}
```
... so that a user can typically select the first result in your autocomplete.

## Customization

`CLTokenInputView` is customizable using:

- `tintColor` — Adjust the selection and text colors.
- `fieldView` — (Optional) View to show to the top left of the tokens.
- `fieldName` — (Optional, but recommended) Text to show before the token list (e.g. **"To:"**)
- `placeholderText` — (Optional, but recommended) Text to show as a hint for the text field.
- `accessoryView` — (Optional) View to show on the top right. (Often to launch a contact picker, like in Mail.app).
- `keyboardType` — Adjust the keyboard type (`UIKeyboardType`).
- `autocapitalizationType` — Adjust the capitalization behavior (`UITextAutocapitalizationType`).
- `autocorrectionType` — Adjust the autocorrection behavior (`UITextAutocorrectionType`).
- `drawBottomBorder` — Set to YES if CLTokenInputView should draw a native-style border below itself.

## Things I'd Like To Do:

- Build the "collapsed" mode like in Mail.app which replaces the token UI with "[first-item] and N more"
- Call search about 150ms after pausing typing
- Scroll text field into position after typing
- (Maybe?) Look into adding a very generic, flexible autocomplete UI?

## Installation

CLTokenInputView is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

    pod "CLTokenInputView"
    
Or, you can take all the .h and .m files from `CLTokenInputView/CLTokenInputView`.

## Author

Cluster Labs, Inc., info@getcluster.com

## License

CLTokenInputView is available under the MIT license. See the LICENSE file for more info.



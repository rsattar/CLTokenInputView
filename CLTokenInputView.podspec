#
#  Be sure to run `pod spec lint CLTokenInputView.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see http://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |s|
  s.name         = "CLTokenInputView"
  s.version      = "2.5.0"
  s.summary      = "A replica of iOS's native contact bubbles UI."
  s.description  = <<-DESC
                   CLTokenInputView is an almost pixel-perfect replica of iOS's contact bubbles
                   input UI (seen in Mail.app and Messages.app). It *does not* implement any
                   autocomplete UI, just the UI where you can enter text into a text field and 
                   bubbles which are deletable using the backspace key. 

                   Check out the sample view controller which uses CLTokenInputView to see how to
                   incorporate it into your UI. We use this in our apps at [Cluster Labs, Inc.](https://cluster.co).

                   Things I'd like to maybe add in the future (or you can help contribute):
                   * Build the "collapsed" mode like in Mail.app which replaces the token UI with
                   "[first-item] and N more"
                   * Call search about 150ms after pausing typing
                   * Scroll text field into position after typing
                   * (Maybe?) Look into adding a very generic, flexible autocomplete UI?
                   DESC

  s.homepage     = "https://github.com/ClusterInc/CLTokenInputView"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author             = { "Rizwan Sattar" => "rsattar@gmail.com" }
  s.social_media_url   = "http://twitter.com/rizzledizzle"
  s.platform     = :ios, "9.0"
  s.source       = { :git => "https://github.com/Dockwa/CLTokenInputView.git", :tag => s.version.to_s }
  s.source_files  = "CLTokenInputView/CLTokenInputView", "CLTokenInputView/CLTokenInputView/**/*.{h,m}"
  s.exclude_files = "CLTokenInputView/CLTokenInputView/Exclude"
  s.requires_arc = true
end

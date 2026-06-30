ARCHS = arm64 arm64e
DEBUG = 0
FINALPACKAGE = 1
FOR_RELEASE = 1

include $(THEOS)/makefiles/common.mk

# گۆڕینی ناوی TWEAK بۆ LIBRARY
LIBRARY_NAME = pool

$(LIBRARY_NAME)_FRAMEWORKS = UIKit Foundation Security QuartzCore CoreGraphics CoreText AVFoundation Accelerate GLKit SystemConfiguration GameController Metal MetalKit

$(LIBRARY_NAME)_CCFLAGS = -std=c++11 -fno-rtti -fno-exceptions -DNDEBUG
$(LIBRARY_NAME)_CFLAGS = -fobjc-arc -Wno-deprecated-declarations -Wno-unused-variable -Wno-unused-value

# زیادکردنی کتێبخانەی دۆبی
$(LIBRARY_NAME)_OBJ_FILES = 5Toubun/libdobby.a

$(LIBRARY_NAME)_FILES = ImGuiDrawView.mm $(wildcard Esp/*.mm) $(wildcard Esp/*.m) $(wildcard IMGUI/*.cpp) $(wildcard IMGUI/*.mm)

# گۆڕینی جۆری بونیادنان بۆ library.mk
include $(THEOS_MAKE_PATH)/library.mk

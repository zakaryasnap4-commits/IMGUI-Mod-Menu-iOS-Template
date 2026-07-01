// Require standard library
#import <Metal/Metal.h>
#import <MetalKit/MetalKit.h>
#import <Foundation/Foundation.h>
#include <mach-o/dyld.h>

// Imgui library
#import "Esp/CaptainHook.h"
#import "Esp/ImGuiDrawView.h"
#import "IMGUI/imgui.h"
#import "IMGUI/imgui_impl_metal.h"
#import "IMGUI/zzz.h"

// Patch library
#import "5Toubun/NakanoIchika.h"
#import "5Toubun/NakanoNino.h"
#import "5Toubun/NakanoMiku.h"
#import "5Toubun/NakanoYotsuba.h"
#import "5Toubun/NakanoItsuki.h"
#import "5Toubun/dobby.h"
#import "5Toubun/il2cpp.h"

// font
#import "RobotoRegular.h"

// macros
#define HOOK(a, b, c) DobbyHook((void*)getRealOffset(a), (void*)b, (void**)&c)

#define kScale [UIScreen mainScreen].scale
#define patch_NULL(a, b) vm(ENCRYPTOFFSET(a), strtoul(ENCRYPTHEX(b), nullptr, 0))
#define patch(a, b) vm_unity(ENCRYPTOFFSET(a), strtoul(ENCRYPTHEX(b), nullptr, 0))

// Get main binary base address for Non-Jailbreak sideloading
static uintptr_t get_binary_base() {
    return (uintptr_t)_dyld_get_image_header(0);
}

@interface ImGuiDrawView () <MTKViewDelegate>
@property (nonatomic, strong) id <MTLDevice> device;
@property (nonatomic, strong) id <MTLCommandQueue> commandQueue;
@end

@implementation ImGuiDrawView

void loadHooks() {
    
}

void setup(){
    Il2CppAttach();
    IL2CPP::il2cpp_thread_attach(IL2CPP::il2cpp_domain_get());
    
    // -------------------------------------------------------------------------
    // ANTI-SIDELOAD & INTEGRITY BYPASS (Executes automatically on launch)
    // -------------------------------------------------------------------------
    uintptr_t base = get_binary_base();
    if (base > 0) {
        // Hex for: mov x0, #0; ret (Returns False/Nil to disable checks)
        uint8_t patch_false[8] = {0x00, 0x00, 0x80, 0xD2, 0xC0, 0x03, 0x5F, 0xD6}; 
        
        // 1. Disable storing environment info (dev-build detection)
        DobbyCodePatch((void*)(base + 0x12CE124), (uint8_t*)patch_false, 8);
        
        // 2. Disable symbol table file URL detection
        DobbyCodePatch((void*)(base + 0x12CE4B8), (uint8_t*)patch_false, 8);
        
        // 3. Disable internal issue reporting (exclc / excst / symbolTable)
        DobbyCodePatch((void*)(base + 0x12CECDC), (uint8_t*)patch_false, 8);
        DobbyCodePatch((void*)(base + 0x12CEF74), (uint8_t*)patch_false, 8);
        DobbyCodePatch((void*)(base + 0x12CE808), (uint8_t*)patch_false, 8);
        
        // 4. Disable crash reporting framework initialization completely
        DobbyCodePatch((void*)(base + 0x12CDA08), (uint8_t*)patch_false, 8);
    }
    
    loadHooks();
}

static bool MenDeal = true;

- (instancetype)initWithNibName:(nullable NSString *)nibNameOrNil bundle:(nullable NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];

    _device = MTLCreateSystemDefaultDevice();
    _commandQueue = [_device newCommandQueue];

    if (!self.device) abort();
    setup();
    
    IMGUI_CHECKVERSION();
    ImGui::CreateContext();
    ImGuiIO& io = ImGui::GetIO(); (void)io;

    ImGuiStyle& style = ImGui::GetStyle();
    ImVec4* colors = style.Colors;

    colors[ImGuiCol_WindowBg]           = ImVec4(0.10f, 0.10f, 0.10f, 1.00f);
    colors[ImGuiCol_ChildBg]            = ImVec4(0.15f, 0.15f, 0.15f, 1.00f);
    colors[ImGuiCol_PopupBg]            = ImVec4(0.12f, 0.12f, 0.12f, 1.00f);

    colors[ImGuiCol_Border]             = ImVec4(0.25f, 0.25f, 0.25f, 0.50f);
    colors[ImGuiCol_Separator]          = ImVec4(0.28f, 0.28f, 0.28f, 1.00f);

    colors[ImGuiCol_Text]               = ImVec4(0.95f, 0.96f, 0.98f, 1.00f);
    colors[ImGuiCol_TextDisabled]       = ImVec4(0.50f, 0.50f, 0.50f, 1.00f);

    colors[ImGuiCol_Header]             = ImVec4(0.20f, 0.22f, 0.27f, 1.00f);
    colors[ImGuiCol_HeaderHovered]      = ImVec4(0.35f, 0.40f, 0.50f, 1.00f);
    colors[ImGuiCol_HeaderActive]       = ImVec4(0.25f, 0.30f, 0.40f, 1.00f);

    colors[ImGuiCol_Button]             = ImVec4(0.20f, 0.25f, 0.30f, 1.00f);
    colors[ImGuiCol_ButtonHovered]      = ImVec4(0.35f, 0.40f, 0.45f, 1.00f);
    colors[ImGuiCol_ButtonActive]       = ImVec4(0.15f, 0.20f, 0.25f, 1.00f);

    colors[ImGuiCol_FrameBg]            = ImVec4(0.18f, 0.18f, 0.18f, 1.00f);
    colors[ImGuiCol_FrameBgHovered]     = ImVec4(0.25f, 0.25f, 0.25f, 1.00f);
    colors[ImGuiCol_FrameBgActive]      = ImVec4(0.20f, 0.20f, 0.20f, 1.00f);

    colors[ImGuiCol_Tab]                = ImVec4(0.15f, 0.18f, 0.22f, 1.00f);
    colors[ImGuiCol_TabHovered]         = ImVec4(0.38f, 0.50f, 0.64f, 1.00f);
    colors[ImGuiCol_TabActive]          = ImVec4(0.28f, 0.35f, 0.48f, 1.00f);
    colors[ImGuiCol_TabUnfocused]       = ImVec4(0.15f, 0.18f, 0.22f, 1.00f);
    colors[ImGuiCol_TabUnfocusedActive] = ImVec4(0.20f, 0.25f, 0.30f, 1.00f);

    colors[ImGuiCol_TitleBg]            = ImVec4(0.12f, 0.12f, 0.12f, 1.00f);
    colors[ImGuiCol_TitleBgActive]      = ImVec4(0.15f, 0.20f, 0.25f, 1.00f);
    colors[ImGuiCol_TitleBgCollapsed]   = ImVec4(0.08f, 0.08f, 0.08f, 1.00f);

    colors[ImGuiCol_ScrollbarBg]        = ImVec4(0.02f, 0.02f, 0.02f, 0.39f);
    colors[ImGuiCol_ScrollbarGrab]      = ImVec4(0.20f, 0.25f, 0.30f, 1.00f);
    colors[ImGuiCol_ScrollbarGrabHovered]= ImVec4(0.25f, 0.30f, 0.35f, 1.00f);
    colors[ImGuiCol_ScrollbarGrabActive]= ImVec4(0.30f, 0.35f, 0.40f, 1.00f);

    ImGui::GetStyle().WindowPadding     = ImVec2(20, 20);
    ImGui::GetStyle().FramePadding      = ImVec2(10, 10);
    ImGui::GetStyle().ItemSpacing       = ImVec2(10, 10);
    ImGui::GetStyle().ItemInnerSpacing  = ImVec2(8, 8);

    ImGui::GetStyle().WindowRounding    = 10.0f;
    ImGui::GetStyle().FrameRounding     = 8.0f;
    ImGui::GetStyle().GrabRounding      = 8.0f;
    ImGui::GetStyle().TabRounding       = 8.0f;
    
    ImFontConfig font_cfg;
    font_cfg.FontDataOwnedByAtlas = false;
    ImGui::GetIO().Fonts->AddFontFromMemoryTTF(RobotoRegular, sizeof(RobotoRegular), 17, &font_cfg);
    
    ImGui_ImplMetal_Init(_device);

    return self;
}

+ (void)showChange:(BOOL)open
{
    MenDeal = open;
}

- (MTKView *)mtkView
{
    return (MTKView *)self.view;
}

- (void)loadView
{
    CGFloat w = [UIApplication sharedApplication].windows[0].rootViewController.view.frame.size.width;
    CGFloat h = [UIApplication sharedApplication].windows[0].rootViewController.view.frame.size.height;
    self.view = [[MTKView alloc] initWithFrame:CGRectMake(0, 0, w, h)];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.mtkView.device = self.device;
    self.mtkView.delegate = self;
    self.mtkView.clearColor = MTLClearColorMake(0, 0, 0, 0);
    self.mtkView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0];
    self.mtkView.clipsToBounds = YES;
}

#pragma mark - Interaction

- (void)updateIOWithTouchEvent:(UIEvent *)event
{
    UITouch *anyTouch = event.allTouches.anyObject;
    CGPoint touchLocation = [anyTouch locationInView:self.view];
    ImGuiIO &io = ImGui::GetIO();
    io.MousePos = ImVec2(touchLocation.x, touchLocation.y);

    BOOL hasActiveTouch = NO;
    for (UITouch *touch in event.allTouches)
    {
        if (touch.phase != UITouchPhaseEnded && touch.phase != UITouchPhaseCancelled)
        {
            hasActiveTouch = YES;
            break;
        }
    }
    io.MouseDown[0] = hasActiveTouch;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self updateIOWithTouchEvent:event];
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self updateIOWithTouchEvent:event];
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self updateIOWithTouchEvent:event];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self updateIOWithTouchEvent:event];
}

#pragma mark - MTKViewDelegate

- (void)drawInMTKView:(MTKView*)view
{
    ImGuiIO& io = ImGui::GetIO();
    io.DisplaySize.x = view.bounds.size.width;
    io.DisplaySize.y = view.bounds.size.height;

    CGFloat framebufferScale = view.window.screen.scale ?: UIScreen.mainScreen.scale;
    io.DisplayFramebufferScale = ImVec2(framebufferScale, framebufferScale);
    io.DeltaTime = 1 / float(view.preferredFramesPerSecond ?: 120);
    
    id<MTLCommandBuffer> commandBuffer = [self.commandQueue commandBuffer];
    
    if (MenDeal == true) {
        [self.view setUserInteractionEnabled:YES];
    } else if (MenDeal == false) {
        [self.view setUserInteractionEnabled:NO];
    }

    MTLRenderPassDescriptor* renderPassDescriptor = view.currentRenderPassDescriptor;
    if (renderPassDescriptor != nil)
    {
        id <MTLRenderCommandEncoder> renderEncoder = [commandBuffer renderCommandEncoderWithDescriptor:renderPassDescriptor];
        [renderEncoder pushDebugGroup:@"ImGui Jane"];

        ImGui_ImplMetal_NewFrame(renderPassDescriptor);
        ImGui::NewFrame();
        
        ImFont* font = ImGui::GetFont();
        font->Scale = 15.f / font->FontSize;
        
        CGFloat x = (([UIApplication sharedApplication].windows[0].rootViewController.view.frame.size.width) - 360) / 2;
        CGFloat y = (([UIApplication sharedApplication].windows[0].rootViewController.view.frame.size.height) - 300) / 2;
        
        ImGui::SetNextWindowPos(ImVec2(x, y), ImGuiCond_FirstUseEver);
        ImGui::SetNextWindowSize(ImVec2(500, 400), ImGuiCond_FirstUseEver);
        
        if (MenDeal == true)
        {
            ImGui::Begin("MOD MENU");

            if (ImGui::BeginTabBar("MainTabBar")) {
            
                if (ImGui::BeginTabItem("Main")) {
                    
                    static bool line_hack_toggle = false;
                    if (ImGui::Checkbox("Long Guideline", &line_hack_toggle)) {
                        uintptr_t base = get_binary_base();
                        if (base > 0) {
                            uint8_t patch_true[8] = {0x01, 0x00, 0x80, 0xD2, 0xC0, 0x03, 0x5F, 0xD6}; // mov x0, #1; ret
                            uint8_t patch_nop[4]  = {0x1F, 0x20, 0x03, 0xD5};                         // nop
                            
                            uint8_t orig_11b488[8]  = {0xFF, 0x43, 0x00, 0xD1, 0xFD, 0x7B, 0x01, 0xA9};
                            uint8_t orig_11b480[4]  = {0x60, 0x6A, 0x28, 0x38};
                            uint8_t orig_30c2fc0[8] = {0x01, 0x9B, 0x00, 0xF0, 0x21, 0x0C, 0x43, 0xF9};

                            if (line_hack_toggle) {
                                DobbyCodePatch((void*)(base + 0x2A3DA8), (uint8_t*)patch_true, 8);
                                DobbyCodePatch((void*)(base + 0x2A3EE4), (uint8_t*)patch_true, 8);
                                DobbyCodePatch((void*)(base + 0x11B488), (uint8_t*)patch_true, 8);
                                DobbyCodePatch((void*)(base + 0x11B480), (uint8_t*)patch_nop, 4);
                                DobbyCodePatch((void*)(base + 0x30C2FC0), (uint8_t*)patch_true, 8);
                            } else {
                                DobbyCodePatch((void*)(base + 0x11B488), (uint8_t*)orig_11b488, 8);
                                DobbyCodePatch((void*)(base + 0x11B480), (uint8_t*)orig_11b480, 4);
                                DobbyCodePatch((void*)(base + 0x30C2FC0), (uint8_t*)orig_30c2fc0, 8);
                            }
                        }
                    }
                    
                    ImGui::EndTabItem();
                }
                
                if (ImGui::BeginTabItem("Combat")) {
                
                    ImGui::EndTabItem();
                }
                
                if (ImGui::BeginTabItem("Misc")) {
                    
                    static bool antiban_toggle = false;
                    if (ImGui::Checkbox("Anti-Ban", &antiban_toggle)) {
                        uintptr_t base = get_binary_base();
                        if (base > 0) {
                            uint8_t patch_true[8]   = {0x01, 0x00, 0x80, 0xD2, 0xC0, 0x03, 0x5F, 0xD6}; // mov x0, #1; ret
                            uint8_t orig_2fdcaa0[8] = {0x61, 0xA0, 0x00, 0xF0, 0x21, 0x50, 0x46, 0xF9};
                            
                            if (antiban_toggle) {
                                DobbyCodePatch((void*)(base + 0x2FDCAA0), (uint8_t*)patch_true, 8);
                            } else {
                                DobbyCodePatch((void*)(base + 0x2FDCAA0), (uint8_t*)orig_2fdcaa0, 8);
                            }
                        }
                    }
                    
                    static bool creator_mode_toggle = false;
                    if (ImGui::Checkbox("Creator Mode", &creator_mode_toggle)) {
                        uintptr_t base = get_binary_base();
                        if (base > 0) {
                            uint8_t patch_true[8]   = {0x01, 0x00, 0x80, 0xD2, 0xC0, 0x03, 0x5F, 0xD6}; // mov x0, #1; ret
                            uint8_t orig_creator[8] = {0xFF, 0x43, 0x00, 0xD1, 0xFD, 0x7B, 0x01, 0xA9};
                            
                            if (creator_mode_toggle) {
                                DobbyCodePatch((void*)(base + 0x11BC4C), (uint8_t*)patch_true, 8);
                            } else {
                                DobbyCodePatch((void*)(base + 0x11BC4C), (uint8_t*)orig_creator, 8);
                            }
                        }
                    }
                
                    ImGui::EndTabItem();
                }
                
                if (ImGui::BeginTabItem("Test")) {
                
                    ImGui::EndTabItem();
                }
                
                ImGui::EndTabBar();
            }

            ImGui::End();
        }
        
        ImDrawList* draw_list = ImGui::GetBackgroundDrawList();

        ImGui::Render();
        ImDrawData* draw_data = ImGui::GetDrawData();
        ImGui_ImplMetal_RenderDrawData(draw_data, commandBuffer, renderEncoder);
      
        [renderEncoder popDebugGroup];
        [renderEncoder endEncoding];

        [commandBuffer presentDrawable:view.currentDrawable];
    }

    [commandBuffer commit];
}

- (void)mtkView:(MTKView*)view drawableSizeWillChange:(CGSize)size
{
    
}

@end

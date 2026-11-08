// Fixed geometry, public AppKit API: clang -fobjc-arc -framework Cocoa main.m -o Gallery
#import <Cocoa/Cocoa.h>
#include <stdio.h>

@interface GalleryDelegate : NSObject <NSApplicationDelegate, NSTableViewDataSource>
@property(strong) NSWindow *window;
@property(strong) NSTextField *input;
@property(strong) NSTextField *stepValue;
@property(strong) NSMutableArray<NSButton *> *radios;
@end

@implementation GalleryDelegate

- (NSTextField *)label:(NSString *)text frame:(NSRect)frame
{
    NSTextField *label = [[NSTextField alloc] initWithFrame:frame];
    [label setStringValue:text];
    [label setEditable:NO];
    [label setSelectable:NO];
    [label setBordered:NO];
    [label setDrawsBackground:NO];
    [label setFont:[NSFont systemFontOfSize:11]];
    [[self.window contentView] addSubview:label];
    return label;
}

- (NSButton *)button:(NSString *)title frame:(NSRect)frame type:(NSButtonType)type
{
    NSButton *button = [[NSButton alloc] initWithFrame:frame];
    [button setButtonType:type];
    [button setTitle:title];
    [[button cell] setControlSize:NSRegularControlSize];
    [button setFont:[NSFont systemFontOfSize:13]];
    if (type == NSMomentaryPushInButton) [button setBezelStyle:NSRoundedBezelStyle];
    [[self.window contentView] addSubview:button];
    return button;
}

- (void)noop:(id)sender {}
- (void)selectRadio:(NSButton *)sender
{
    for (NSButton *button in self.radios) [button setState:button == sender ? NSOnState : NSOffState];
}
- (void)step:(NSStepper *)sender { [self.stepValue setIntegerValue:[sender integerValue]]; }
- (void)toggle:(NSMenuItem *)sender { [sender setState:[sender state] == NSOnState ? NSOffState : NSOnState]; }

- (void)buildMenu
{
    NSMenu *bar = [[NSMenu alloc] initWithTitle:@"Control Gallery"];
    for (NSString *title in @[@"App", @"File", @"Edit", @"View"]) {
        NSMenuItem *top = [[NSMenuItem alloc] initWithTitle:title action:NULL keyEquivalent:@""];
        NSMenu *menu = [[NSMenu alloc] initWithTitle:title];
        [top setSubmenu:menu];
        [bar addItem:top];
        if ([title isEqualToString:@"App"]) {
            [menu addItemWithTitle:@"About Control Gallery" action:@selector(orderFrontStandardAboutPanel:) keyEquivalent:@""];
            [menu addItem:[NSMenuItem separatorItem]];
            [menu addItemWithTitle:@"Hide Control Gallery" action:@selector(hide:) keyEquivalent:@"h"];
            [menu addItemWithTitle:@"Quit Control Gallery" action:@selector(terminate:) keyEquivalent:@"q"];
        } else if ([title isEqualToString:@"File"]) {
            [menu setAutoenablesItems:NO];
            id item = [menu addItemWithTitle:@"New" action:@selector(noop:) keyEquivalent:@"n"];
            [item setTarget:self];
            id recent = [menu addItemWithTitle:@"Open Recent" action:NULL keyEquivalent:@""];
            NSMenu *submenu = [[NSMenu alloc] initWithTitle:@"Open Recent"];
            item = [submenu addItemWithTitle:@"Sample Document" action:@selector(noop:) keyEquivalent:@""];
            [item setTarget:self];
            [recent setSubmenu:submenu];
            [menu addItem:[NSMenuItem separatorItem]];
            item = [menu addItemWithTitle:@"Save" action:@selector(noop:) keyEquivalent:@"s"];
            [item setEnabled:NO];
            [menu addItemWithTitle:@"Close" action:@selector(performClose:) keyEquivalent:@"w"];
        } else if ([title isEqualToString:@"Edit"]) {
            [menu addItemWithTitle:@"Undo" action:@selector(undo:) keyEquivalent:@"z"];
            [menu addItem:[NSMenuItem separatorItem]];
            [menu addItemWithTitle:@"Cut" action:@selector(cut:) keyEquivalent:@"x"];
            [menu addItemWithTitle:@"Copy" action:@selector(copy:) keyEquivalent:@"c"];
            [menu addItemWithTitle:@"Paste" action:@selector(paste:) keyEquivalent:@"v"];
            [menu addItemWithTitle:@"Select All" action:@selector(selectAll:) keyEquivalent:@"a"];
        } else {
            id item = [menu addItemWithTitle:@"Show Details" action:@selector(toggle:) keyEquivalent:@"d"];
            [item setTarget:self];
            [item setState:NSOnState];
        }
    }
    [NSApp setMainMenu:bar];
}

- (void)buildWindow
{
    self.window = [[NSWindow alloc] initWithContentRect:NSMakeRect(0, 0, 760, 560)
        styleMask:NSWindowStyleMaskTitled | NSWindowStyleMaskClosable | NSWindowStyleMaskMiniaturizable
        backing:NSBackingStoreBuffered defer:NO];
    [self.window setTitle:@"Control Gallery"];
    NSView *view = [self.window contentView];
    [self label:@"Push buttons" frame:NSMakeRect(16, 530, 120, 18)];
    [self button:@"Normal" frame:NSMakeRect(134, 522, 100, 30) type:NSMomentaryPushInButton];
    NSButton *button = [self button:@"Default" frame:NSMakeRect(238, 522, 100, 30) type:NSMomentaryPushInButton];
    [button setKeyEquivalent:@"\r"];
    button = [self button:@"Disabled" frame:NSMakeRect(342, 522, 100, 30) type:NSMomentaryPushInButton];
    [button setEnabled:NO];
    button = [self button:@"Small" frame:NSMakeRect(448, 526, 80, 22) type:NSMomentaryPushInButton];
    [[button cell] setControlSize:NSSmallControlSize];
    [button setFont:[NSFont systemFontOfSize:11]];
    [self label:@"Regular / small" frame:NSMakeRect(540, 530, 160, 18)];

    [self label:@"Checkboxes" frame:NSMakeRect(16, 494, 110, 18)];
    NSArray *checks = @[@"Off", @"On", @"Mixed", @"Disabled"];
    for (NSUInteger i = 0; i < checks.count; i++) {
        button = [self button:checks[i] frame:NSMakeRect(134 + i * 110, 490, 106, 24) type:NSSwitchButton];
        if (i == 2) [button setAllowsMixedState:YES];
        [button setState:i == 1 ? NSOnState : (i == 2 ? NSMixedState : NSOffState)];
        [button setEnabled:i != 3];
    }
    [self label:@"Radio group" frame:NSMakeRect(16, 460, 110, 18)];
    self.radios = [NSMutableArray array];
    for (NSUInteger i = 0; i < 3; i++) {
        button = [self button:@[@"First", @"Second", @"Disabled"][i]
            frame:NSMakeRect(134 + i * 110, 456, 106, 24) type:NSRadioButton];
        [button setState:i == 0 ? NSOnState : NSOffState];
        [button setEnabled:i != 2];
        [button setTarget:self]; [button setAction:@selector(selectRadio:)];
        [self.radios addObject:button];
    }

    [self label:@"Pop-up" frame:NSMakeRect(16, 425, 70, 18)];
    NSPopUpButton *popup = [[NSPopUpButton alloc] initWithFrame:NSMakeRect(84, 420, 145, 26) pullsDown:NO];
    [popup addItemsWithTitles:@[@"First", @"Second", @"Third"]]; [view addSubview:popup];
    [self label:@"Pull-down" frame:NSMakeRect(242, 425, 70, 18)];
    popup = [[NSPopUpButton alloc] initWithFrame:NSMakeRect(312, 420, 140, 26) pullsDown:YES];
    [popup addItemsWithTitles:@[@"Actions", @"Inspect", @"Reset"]]; [view addSubview:popup];
    [self label:@"Combo" frame:NSMakeRect(466, 425, 54, 18)];
    NSComboBox *combo = [[NSComboBox alloc] initWithFrame:NSMakeRect(522, 420, 220, 26)];
    [combo addItemsWithObjectValues:@[@"First", @"Second", @"Third"]];
    [combo setStringValue:@"Second"]; [view addSubview:combo];

    NSArray *names = @[@"Placeholder", @"Filled", @"Disabled", @"Secure", @"Search"];
    for (NSUInteger i = 0; i < names.count; i++) {
        CGFloat x = 16 + i * 148;
        [self label:names[i] frame:NSMakeRect(x, 395, 140, 18)];
        Class type = i == 3 ? [NSSecureTextField class] : (i == 4 ? [NSSearchField class] : [NSTextField class]);
        NSTextField *field = [[type alloc] initWithFrame:NSMakeRect(x, 366, 138, 24)];
        [field setFont:[NSFont systemFontOfSize:13]];
        if (i == 0) { [field setPlaceholderString:@"Type here"]; self.input = field; }
        else [field setStringValue:i == 3 ? @"sample" : (i == 4 ? @"Find" : @"Sample text")];
        if (i == 2) [field setEnabled:NO];
        [view addSubview:field];
    }

    [self label:@"Segments" frame:NSMakeRect(16, 333, 75, 18)];
    NSSegmentedControl *segments = [[NSSegmentedControl alloc] initWithFrame:NSMakeRect(94, 328, 225, 26)];
    [segments setSegmentCount:3];
    for (NSInteger i = 0; i < 3; i++) { [segments setLabel:@[@"One", @"Two", @"Three"][i] forSegment:i]; [segments setWidth:70 forSegment:i]; }
    [segments setSelectedSegment:1]; [view addSubview:segments];
    [self label:@"Slider" frame:NSMakeRect(334, 333, 54, 18)];
    for (NSUInteger i = 0; i < 2; i++) {
        NSSlider *slider = [[NSSlider alloc] initWithFrame:NSMakeRect(390 + i * 180, 326, 170, 28)];
        [slider setMinValue:0]; [slider setMaxValue:100]; [slider setDoubleValue:40];
        if (i) [slider setNumberOfTickMarks:5];
        [view addSubview:slider];
    }
    [self label:@"Ticks" frame:NSMakeRect(690, 351, 50, 16)];

    [self label:@"Stepper" frame:NSMakeRect(16, 296, 65, 18)];
    NSStepper *stepper = [[NSStepper alloc] initWithFrame:NSMakeRect(85, 288, 20, 28)];
    [stepper setMinValue:0]; [stepper setMaxValue:10]; [stepper setIntegerValue:4];
    [stepper setTarget:self]; [stepper setAction:@selector(step:)]; [view addSubview:stepper];
    self.stepValue = [self label:@"4" frame:NSMakeRect(112, 296, 30, 18)];
    [self label:@"Progress 40%" frame:NSMakeRect(150, 296, 90, 18)];
    for (NSUInteger i = 0; i < 3; i++) {
        NSProgressIndicator *progress = [[NSProgressIndicator alloc] initWithFrame:
            i == 2 ? NSMakeRect(710, 288, 28, 28) : NSMakeRect(244 + i * 235, 296, 160, 16)];
        [progress setStyle:i == 2 ? NSProgressIndicatorSpinningStyle : NSProgressIndicatorBarStyle];
        [progress setIndeterminate:i != 0]; [progress setMinValue:0]; [progress setMaxValue:100];
        [progress setDoubleValue:40]; [view addSubview:progress];
        if (i) [progress startAnimation:nil];
    }
    [self label:@"Busy" frame:NSMakeRect(438, 296, 40, 18)];
    [self label:@"Spinner" frame:NSMakeRect(651, 296, 58, 18)];

    NSBox *separator = [[NSBox alloc] initWithFrame:NSMakeRect(16, 278, 728, 2)];
    [separator setBoxType:NSBoxSeparator]; [view addSubview:separator];
    [self label:@"Table: 8 rows, second selected" frame:NSMakeRect(16, 251, 300, 18)];
    NSScrollView *scroll = [[NSScrollView alloc] initWithFrame:NSMakeRect(16, 78, 352, 170)];
    [scroll setHasVerticalScroller:YES]; [scroll setAutohidesScrollers:NO]; [scroll setBorderType:NSBezelBorder];
    NSTableView *table = [[NSTableView alloc] initWithFrame:NSMakeRect(0, 0, 330, 200)];
    for (NSString *name in @[@"Item", @"State"]) {
        NSTableColumn *column = [[NSTableColumn alloc] initWithIdentifier:name];
        [[column headerCell] setStringValue:name]; [column setWidth:160]; [table addTableColumn:column];
    }
    [table setRowHeight:22]; [table setUsesAlternatingRowBackgroundColors:YES]; [table setDataSource:self];
    [scroll setDocumentView:table]; [view addSubview:scroll]; [table reloadData];
    [table selectRowIndexes:[NSIndexSet indexSetWithIndex:1] byExtendingSelection:NO];

    NSTabView *tabs = [[NSTabView alloc] initWithFrame:NSMakeRect(390, 150, 352, 116)];
    for (NSString *title in @[@"First tab", @"Second tab"]) {
        NSTabViewItem *tab = [[NSTabViewItem alloc] initWithIdentifier:title]; [tab setLabel:title];
        NSView *page = [[NSView alloc] initWithFrame:NSMakeRect(0, 0, 320, 70)];
        NSTextField *label = [[NSTextField alloc] initWithFrame:NSMakeRect(12, 24, 280, 20)];
        [label setStringValue:[title stringByAppendingString:@" content"]];
        [label setEditable:NO]; [label setBordered:NO]; [label setDrawsBackground:NO];
        [label setFont:[NSFont systemFontOfSize:13]]; [page addSubview:label];
        [tab setView:page]; [tabs addTabViewItem:tab];
    }
    [view addSubview:tabs];
    NSBox *box = [[NSBox alloc] initWithFrame:NSMakeRect(390, 78, 352, 64)];
    [box setTitle:@"Titled box"]; [view addSubview:box];

    [self label:@"Colour" frame:NSMakeRect(16, 31, 50, 18)];
    NSColorWell *well = [[NSColorWell alloc] initWithFrame:NSMakeRect(70, 23, 50, 30)]; [view addSubview:well];
    [self label:@"Date" frame:NSMakeRect(144, 31, 40, 18)];
    NSDatePicker *date = [[NSDatePicker alloc] initWithFrame:NSMakeRect(186, 25, 190, 26)];
    [date setDatePickerStyle:NSTextFieldAndStepperDatePickerStyle];
    [date setDatePickerElements:NSYearMonthDayDatePickerElementFlag];
    [date setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    [date setDateValue:[NSDate dateWithTimeIntervalSince1970:946684800]]; [view addSubview:date];
    [self label:@"Level" frame:NSMakeRect(400, 31, 50, 18)];
    Class levelClass = NSClassFromString(@"NSLevelIndicator");
    if (levelClass) {
        NSLevelIndicator *level = [[levelClass alloc] initWithFrame:NSMakeRect(455, 29, 180, 20)];
        [level setMinValue:0]; [level setMaxValue:10]; [level setDoubleValue:4]; [view addSubview:level];
    } else [self label:@"Unavailable" frame:NSMakeRect(455, 31, 180, 18)];
    [self.window center]; [self.window makeKeyAndOrderFront:nil];
    [self.window makeFirstResponder:nil];
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)table { return 8; }
- (id)tableView:(NSTableView *)table objectValueForTableColumn:(NSTableColumn *)column row:(NSInteger)row
{
    return [[column identifier] isEqual:@"Item"] ? [NSString stringWithFormat:@"Item %ld", (long)row + 1]
        : @[@"Ready", @"Selected", @"Ready", @"Pending", @"Ready", @"Pending", @"Ready", @"Ready"][(NSUInteger)row];
}

- (void)openRequestedMenu:(NSTimer *)timer
{
    NSString *title = [timer userInfo];
    NSMenu *menu = [[[NSApp mainMenu] itemWithTitle:title] submenu];
    if (!menu || ![NSMenu respondsToSelector:@selector(popUpContextMenu:withEvent:forView:)]) {
        fprintf(stderr, "gallery: cannot open menu '%s'\n", [title UTF8String]);
        return;
    }
    NSEvent *event = [NSEvent mouseEventWithType:NSRightMouseDown location:NSMakePoint(20, 550)
        modifierFlags:0 timestamp:0 windowNumber:[self.window windowNumber] context:nil eventNumber:0 clickCount:1 pressure:1];
    [NSMenu popUpContextMenu:menu withEvent:event forView:[self.window contentView]];
}
- (void)quit:(NSTimer *)timer { [NSApp terminate:nil]; }
- (void)applicationDidFinishLaunching:(NSNotification *)notification
{
    [self buildMenu]; [self buildWindow];
    [NSApp activateIgnoringOtherApps:YES];
    NSDictionary *env = [[NSProcessInfo processInfo] environment];
    if ([env[@"GALLERY_FOCUS"] isEqualToString:@"1"]) [self.window makeFirstResponder:self.input];
    double delay = [env[@"GALLERY_QUIT_AFTER"] doubleValue];
    if (delay > 0) {
        // Common + tracking modes keep the deadline active while a menu is open.
        NSTimer *timer = [NSTimer timerWithTimeInterval:delay target:self selector:@selector(quit:) userInfo:nil repeats:NO];
        [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
        [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSEventTrackingRunLoopMode];
    }
    // The window number is the CGWindowID on macOS: `screencapture -l <n>` captures
    // exactly this window (used by the macOS reference CI job).
    fprintf(stderr, "gallery: ready window=%ld\n", (long)[self.window windowNumber]); fflush(stderr);
    if ([env[@"GALLERY_MENU"] length])
        [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(openRequestedMenu:) userInfo:env[@"GALLERY_MENU"] repeats:NO];
}
- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)app { return YES; }
@end

int main(int argc, const char *argv[])
{
    @autoreleasepool {
        NSApplication *app = [NSApplication sharedApplication];
        // A bare executable (no .app bundle) must ask to be a regular, activatable
        // app; otherwise macOS shows it inactive (grey title buttons, no accent).
        [app setActivationPolicy:NSApplicationActivationPolicyRegular];
        GalleryDelegate *delegate = [[GalleryDelegate alloc] init];
        [app setDelegate:delegate]; [app run];
    }
    return 0;
}


#include <utility>

#include "base/base64.h"
#include "base/callback.h"
#include "base/no_destructor.h"
#include "ui/views/views_features.h"
#include "ui/views/widget/drop_helper.h"
#include "ui/views/widget/native_widget_delegate.h"
#include "ui/views/widget/widget_delegate.h"
#include "ui/views/window/native_frame_view.h"
#include "ui/views/widget/native_widget_private.h"

DEFINE_UI_CLASS_PROPERTY_TYPE(views::internal::NativeWidgetPrivate*)

namespace views {


namespace internal {

////////////////////////////////////////////////////////////////////////////////
// internal::NativeWidgetPrivate, public:

// static
NativeWidgetPrivate* NativeWidgetPrivate::CreateNativeWidget(
    internal::NativeWidgetDelegate* delegate) {
    return nullptr;
}

// static
NativeWidgetPrivate* NativeWidgetPrivate::GetNativeWidgetForNativeView(
    ui::ViewAndroid* native_view) {
    return nullptr;
}


// static
NativeWidgetPrivate* NativeWidgetPrivate::GetNativeWidgetForNativeWindow(
    ui::WindowAndroid* native_window) {
return nullptr;
}

// static
NativeWidgetPrivate* NativeWidgetPrivate::GetTopLevelNativeWidget(
    ui::ViewAndroid* native_view) {
return nullptr;
}

// static
void NativeWidgetPrivate::GetAllChildWidgets(ui::ViewAndroid* native_view,
                                             Widget::Widgets* children) {
}

// static
void NativeWidgetPrivate::GetAllOwnedWidgets(ui::ViewAndroid* native_view,
                                             Widget::Widgets* owned) {
}

// static
void NativeWidgetPrivate::ReparentNativeView(ui::ViewAndroid* native_view,
                                             ui::ViewAndroid* new_parent) {
}

// static
ui::ViewAndroid* NativeWidgetPrivate::GetGlobalCapture(
    ui::ViewAndroid* native_view) {
    return nullptr;
}

}  // namespace internal
}  // namespace views

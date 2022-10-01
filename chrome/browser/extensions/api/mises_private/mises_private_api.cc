#include "chrome/browser/extensions/api/mises_private/mises_private_api.h"
#include "extensions/browser/extension_function_registry.h"
#include "extensions/common/extension.h"
#include "base/logging.h"
#include "chrome/browser/android/mises/mises_controller.h"
#include "base/android/sys_utils.h"

namespace extensions {
MisesPrivateSetMisesIdFunction::~MisesPrivateSetMisesIdFunction() {}
 
ExtensionFunction::ResponseAction MisesPrivateSetMisesIdFunction::Run() {
  std::unique_ptr<api::mises_private::SetMisesId::Params> params(
      api::mises_private::SetMisesId::Params::Create(args()));
  EXTENSION_FUNCTION_VALIDATE(params.get());
  LOG(INFO) << "set mises id :" << params->id;
  android::MisesController::GetInstance()->setMisesUserInfo(params->id);
  return RespondNow(NoArguments());
}


MisesPrivateGetInstallReferrerFunction::~MisesPrivateGetInstallReferrerFunction() {}
ExtensionFunction::ResponseAction MisesPrivateGetInstallReferrerFunction::Run() {
  std::string referrerString = base::android::SysUtils::ReferrerStringFromJni();
  return RespondNow(ArgumentList(
    api::mises_private::GetInstallReferrer::Results::Create(referrerString)));
}

}  // namespace extensions

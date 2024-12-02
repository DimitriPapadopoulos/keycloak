<#import "template.ftl" as layout>
<#import "field.ftl" as field>
<#import "user-profile-commons.ftl" as userProfileCommons>
<#import "register-commons.ftl" as registerCommons>
<@layout.registrationLayout displayMessage=messagesPerField.exists('global') displayRequiredFields=true; section>
<!-- template: register.ftl -->

    <#if section = "header">
        <#if messageHeader??>
            ${kcSanitize(msg("${messageHeader}"))?no_esc}
        <#else>
            ${msg("registerTitle")}
        </#if>
    <#elseif section = "form">
        <form id="kc-register-form" class="${properties.kcFormClass!}" action="${url.registrationAction}" method="post" novalidate="novalidate">
            <@userProfileCommons.userProfileFormFields; callback, attribute>
                <#if callback = "afterField">
                <#-- render password fields just under the username or email (if used as username) -->
                    <#if passwordRequired?? && (attribute.name == 'username' || (attribute.name == 'email' && realm.registrationEmailAsUsername))>
                        <@field.password name="password" required=true label=msg("password") autocomplete="new-password" />
                        <@field.password name="password-confirm" required=true label=msg("passwordConfirm") autocomplete="new-password" />
                    </#if>
                </#if>
            </@userProfileCommons.userProfileFormFields>

            <@registerCommons.termsAcceptance/>

            <#if recaptchaRequired?? && (recaptchaVisible!false)>
                <div class="form-group">
                    <div class="${properties.kcInputWrapperClass!}">
                        <div class="g-recaptcha" data-size="compact" data-sitekey="${recaptchaSiteKey}" data-action="${recaptchaAction}"></div>
                    </div>
                </div>
            </#if>

            <#if recaptchaRequired?? && !(recaptchaVisible!false)>
                <script>
                    function onSubmitRecaptcha(token) {
                        document.getElementById("kc-register-form").requestSubmit();
                    }
                </script>
                <div id="kc-form-buttons" class="${properties.kcFormButtonsClass!}">
                    <button class="${properties.kcButtonClass!} ${properties.kcButtonPrimaryClass!} ${properties.kcButtonBlockClass!} ${properties.kcButtonLargeClass!} g-recaptcha"
                            data-sitekey="${recaptchaSiteKey}" data-callback="onSubmitRecaptcha" data-action="${recaptchaAction}" type="submit">
                        ${msg("doRegister")}
                    </button>
                </div>
            <#else>
                <div id="kc-form-buttons" class="${properties.kcFormButtonsClass!}">
                    <input class="${properties.kcButtonClass!} ${properties.kcButtonPrimaryClass!} ${properties.kcButtonBlockClass!} ${properties.kcButtonLargeClass!}" type="submit" value="${msg("doRegister")}"/>
                </div>
            </#if>

            <div class="${properties.kcFormGroupClass!} pf-v5-c-login__main-footer-band">
                <div id="kc-form-options" class="${properties.kcFormOptionsClass!} pf-v5-c-login__main-footer-band-item">
                    <div class="${properties.kcFormOptionsWrapperClass!}">
                        <span><a href="${url.loginUrl}">${kcSanitize(msg("backToLogin"))?no_esc}</a></span>
                    </div>
                </div>
            </div>

        </form>

        <template id="errorTemplate">
            <div class="${properties.kcFormHelperTextClass}" aria-live="polite">
                <div class="${properties.kcInputHelperTextClass}">
                    <div class="${properties.kcInputHelperTextItemClass} ${properties.kcError}">
                        <ul class="${properties.kcInputErrorMessageClass}">
                        </ul>
                    </div>
                </div>
            </div>
        </template>
        <template id="errorItemTemplate">
            <li></li>
        </template>

        <script type="module">
            import { validatePassword } from "${url.resourcesPath}/js/password-policy.js";

            const activePolicies = [
                { name: "length", policy: { value: ${passwordPolicies.length!-1}, error: "${msg('invalidPasswordMinLengthMessage')}"} },
                { name: "maxLength", policy: { value: ${passwordPolicies.maxLength!-1}, error: "${msg('invalidPasswordMaxLengthMessage')}"} },
                { name: "lowerCase", policy: { value: ${passwordPolicies.lowerCase!-1}, error: "${msg('invalidPasswordMinLowerCaseCharsMessage')}"} },
                { name: "upperCase", policy: { value: ${passwordPolicies.upperCase!-1}, error: "${msg('invalidPasswordMinUpperCaseCharsMessage')}"} },
                { name: "digits", policy: { value: ${passwordPolicies.digits!-1}, error: "${msg('invalidPasswordMinDigitsMessage')}"} },
                { name: "specialChars", policy: { value: ${passwordPolicies.specialChars!-1}, error: "${msg('invalidPasswordMinSpecialCharsMessage')}"} }
            ].filter(p => p.policy.value !== -1);

            document.getElementById("password").addEventListener("change", (event) => {

                const errorContainer = document.getElementById("input-error-container-password");
                const template = document.querySelector("#errorTemplate").content.cloneNode(true);
                const errors = validatePassword(event.target.value, activePolicies);

                if (errors.length === 0) {
                    errorContainer.replaceChildren();
                    return;
                }

                const errorList = template.querySelector("ul");
                const htmlErrors = errors.forEach((e) => {
                    const row = document.querySelector("#errorItemTemplate").content.cloneNode(true);
                    const li = row.querySelector("li");
                    li.textContent = e;
                    errorList.appendChild(li);
                });
                errorContainer.replaceChildren(template);
            });
        </script>
    </#if>
</@layout.registrationLayout>

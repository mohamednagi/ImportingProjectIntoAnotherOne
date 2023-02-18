//
//  Constants.swift
//
//  Created by Yehia Elbehery.
//


import Foundation



enum ErrorMessageKey {
    case
    User_input_worng_username_or_password,
    User_Deactivated,
    Email_sent_to_reset_password,
     Passcode_not_correct,
    Not_matching_password,
    Empty_username,
    Empty_login_password,
    Empty_email_Username,
    Empty_Password,
    Empty_Passcode,
    Empty_confirm_password,
    Expire_token,
    Password_less_than_6_character_and_doesnt_contain_special_character_or_numbers,
    Username_not_exists,
    Email_not_exists,
    Pasword_setting_success,
    General_Failure,
    edit_profile_success,
    Empty_users_name,
    empty_state,
    camera_access,
    camera_access_from_setting,
    photos_access_from_setting,
    user_mention_more_than_one_image,
    user_exceed_adding_tags_limit,
    User_change_person_or_tags_after_sending_thank_you_post,
    Thank_You_Post_success,
    no_internet_connection,
    no_search_result,
    redeem_success,
    notification_success,
    log_out,
    Thank_You_Post,
    Comment_on_post,
    Profile_Adding_Position_for_non_active_user,
    Profile_Adding_number_for_non_active_user,
    Profile_Adding_name_for_non_active_user
}
class Constants {
    
    static var languageChanged = false
    static var selectedVC = 1
    
    static let platformName: String    = "ios"
    
    static var appStoreId = "0000000000"
    static var filterPersonsPostTypes = [/*"Giving Thanks"*/"Praises Received".y_localized, /*"Receiving Thanks"*/"Compliments Given".y_localized, /*"All Thanks"*/"All".y_localized]
    
    static var fromIntro = false
    
    static func regularFont() -> String {
        return Fonts.regularFont
//        if UserSettings.appLanguageIsArabic() {
//            return "GESSTwoLight-Light"
//        }else{
//            return "SanFranciscoText-Regular"
//        }
    }
    static func mediumFont() -> String {
        return Fonts.mediumFont
//        if UserSettings.appLanguageIsArabic() {
//            return "GESSTwoMedium-Medium"
//        }else{
//            return "SanFranciscoText-Medium"
//        }
    }
    static func boldFont() -> String {
        return Fonts.boldFont
//        if UserSettings.appLanguageIsArabic() {
//            return "GESSTwoBold-Bold"
//        }else{
//            return "SanFranciscoText-Bold"
//        }
    }
    
    static func fontNameConvertedToArabic(fromFontName: String) -> String {
        if UserSettings.appLanguageIsArabic() {
            if fromFontName.contains("-Regular") {
                
                return Constants.regularFont()
                
            }else if fromFontName.contains("-Medium") {
                
                return Constants.mediumFont()
                
            }else if fromFontName.contains("-Bold") || fromFontName.contains("-Semibold") || fromFontName.contains("-Heavy") {
                
                return Constants.boldFont()
            }else {
                return Constants.regularFont()
            }
        }
        return fromFontName
    }
    
    static func fontNameConvertedToEnglish(fromFontName: String) -> String {
        if UserSettings.appLanguageIsArabic() {
            if fromFontName.contains("-Light") {
                
                return Constants.regularFont()
                
            }else if fromFontName.contains("-Medium") {
                
                return Constants.mediumFont()
                
            }else if fromFontName.contains("-Bold") || fromFontName.contains("-Semibold") || fromFontName.contains("-Heavy") {
                
                return Constants.boldFont()
            } else {
            return Constants.regularFont()
        }
        }
        return fromFontName
    }
    
    static func errorMessage(_ errorMessage: ErrorMessageKey) -> String {
        if errorMessages[errorMessage] != nil {
            if UserSettings.appLanguageIsArabic() {
                return Constants.errorMessages[errorMessage]![1]
            }else{
                return Constants.errorMessages[errorMessage]![0]
            }
        }
        return ""
    }
    
    static var errorMessages : [ErrorMessageKey: [String]] = [
        .User_input_worng_username_or_password : [
            "Username or password is incorrect, please try again.",
                                                  "اسم المستخدم أو كلمة السر غير صحيحة، يرجي المحاولة مرة أخري."
        ],
        .User_Deactivated: [
            "Your account is locked, Please contact with system administrator.",
            "حسابك غير مفعل، من فضلك تواصل مع مسئول النظام."
            ],
        .Email_sent_to_reset_password : [
            "The passcode has been sent to your email address ",
            "لقد تم إرسال رمز المرور الي بريدك الالكتروني"
        ],
        .Passcode_not_correct : [
            "The passcode is incorrect , please try again.",
            " رمز المرور غير صحيح ، يرجي المحاولة مرة أخري"
        ],
        .Not_matching_password : [
            "The passwords are not matching, please try again",
            "كلمات السر غير متطابقة، يرجي المحاولة مرة أخري"
        ],
        .Empty_username : [
            "Please enter your username ",
            "من فضلك ادخل اسم المستخدم"
        ],
        .Empty_login_password : [
            "Please enter your password ",
            "من فضلك ادخل كلمة السر"
        ],
        .Empty_email_Username : [
            "Please enter your Email / Username ",
            "من فضلك ادخل البريد الالكتروني/ اسم المستخدم"
        ],
        .Empty_Password : [
            "The password can't be empty",
            "من فضلك ادخل كلمه السر"
        ],
        .Empty_Passcode : [
            "The passcode can't be empty",
            "من فضلك ادخل رمز المرور"
        ],
        .Empty_confirm_password : [
            "The confirm password can't be empty",
            "من فضلك ادخل تاكيد كلمه السر"
        ],
        .Expire_token : [
            "This passcode has been expired, please request new one",
            "لقد انتهت صلاحيه كلمه المرور ، من فضلك اطلب رمز مرور اخر"
        ],
        .Password_less_than_6_character_and_doesnt_contain_special_character_or_numbers : [
            "Your password should be at least 6 characters and contain special characters and numbers ",
            "كلمة السر يجب ان تكون على الاقل 6 حروف و تحتوي علي حروف خاصه وارقام"
        ],
        .Username_not_exists : [
            "The username is incorrect , please try again.",
            "اسم المستخدم غير صحيح ، يرجي المحاولة مرة أخري"
        ],
        .Email_not_exists : [
            "The email is incorrect , please try again.",
            "البريد الالكتروني غير صحيح ، يرجي المحاولة مرة أخري"
        ],
        .Pasword_setting_success : [
            "Your password has been changed successfully",
            "لقد تم تعيين كلمة السر بنجاح"
        ],
        .General_Failure : [
            "Unexpected error, please try again.",
            "خطأ غير متوقع، يرجي المحاولة مرة أخري"
        ],
        .edit_profile_success : [
            "You have edited your profile info successfully. ",
            "لقد تم تعديل معلومات ملفك الشخصي بنجاح"
        ],
        .Empty_users_name : [
            "Please enter your name",
            "من فضلك ادخل اسمك"
        ],
        /*.empty_state : [
            "There are no posts yet,\nStart by motivating your colleagues.",
            "لا توجد منشورات حتي الآن.
            إبدا بتحفيز زملائك"
        ],*/
        /*.camera_access : [
            "\"Motivay\" would like to access your Camera / Photos\nTo be able to take photos with your motivay, you will need to allow this",
            ""
        ],*/
        .camera_access_from_setting : [
            "Please allow Motivay to access the camera from settings",
            "يرجي تمكين الوصول للكاميرا من الاعدادات"
        ],
        .photos_access_from_setting : [
            "Please allow Motivay to access the Photos from settings",
            "يرجي تمكين الوصول للصور من الاعدادات"
        ],
        .user_mention_more_than_one_image : [
            "You can only attach one image",
            "يمكنك إرفاق صورة واحدة فقط"
        ],
        .user_exceed_adding_tags_limit : [
            "Sorry, you can't add more than 3 tags",
            "عذرا، لا يمكنك إضافة أكثر من ٣ أوسمة"
        ],
        .User_change_person_or_tags_after_sending_thank_you_post : [
            "Sorry, you can't change person or tags after sending thank you post",
            "عذرا، لا يمكنك تغيير الشخص أو الأوسمة بعد إرسال رسالة الشكر"
        ],
        /*.Thank_You_Post_success : [
            "",
            ""
        ],*/
        /*.no_internet_connection : [
            "",
            ""
        ],*/
        .no_search_result : [
            "No Results Found\nTry different keywords",
        "لا توجد نتائج.\nحاول إستخدام كلمات أخري"
        ],
        /*.redeem_success : [
            "",
            ""
        ],*/
        .notification_success : [
            /*"There's no notification yet,\nCheck back later for updates"*/"You don't seem to have any notifications,\nCheck back later for updates"
            ,
            "لا توجد إشعارات الآن\n برجاء التحقق مرة أخري في وقت لاحق. "
        ],
        .log_out : [
            "Are you sure you want to log out?",
            "هل أنت متأكد أنك تريد تسجيل الخروج؟"
        ],
        .Thank_You_Post : [
            "You have exceeded characters limit which is 150 characters",
            " لقد تجاوزت الحد الأقصي للحروف وهو 150 حرف"
        ],
        .Comment_on_post : [
            " You have exceeded characters limit which is 150 characters",
            " لقد تجاوزت الحد الأقصي للحروف وهو 150 حرف"
        ],
        .Profile_Adding_Position_for_non_active_user : [
            " You have exceeded characters limit which is 35 characters",
            "لقد تجاوزت الحد الأقصي للحروف وهو 35 حرف"
        ],
        .Profile_Adding_number_for_non_active_user : [
            "You have exceeded numbers limit which is 35 numbers",
            " لقد تجاوزت الحد الأقصي للأرقام وهو 35 رقم"
        ],
        .Profile_Adding_name_for_non_active_user : [
            " You have exceeded characters limit which is 35 characters",
            "لقد تجاوزت الحد الأقصي للحروف وهو 35 حرف"
        ]
    ]
}

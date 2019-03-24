//
//  AnalyticsKeys.swift
//  InstaWeather
//
//  Created by Besher on 2019-02-18.
//  Copyright © 2019 Besher Al Maleh. All rights reserved.
//

import Foundation

enum Event: String {
    case exportButtonTapped = "export_button_tapped" // add screen from whence it came
    case exportFacebook = "export_facebook"
    case exportTwitter = "export_twitter"
    case exportInstagram = "export_instagram"
    case exportSnapchat = "export_snapchat"
    case exportOther = "export_other"
    case memoriesTapped = "memories_tapped"
    case memoriesNewest = "memories_newest"
    case memoriesOldest = "memories_oldest"
    case memoriesRewind = "memories_rewind"
    case memoriesSwipe = "memories_swipe"
    case changeCity = "change_city"
    case tappedAutoCompleteResult = "change_autocomplete"
    case tappedPreviousCity = "change_previous_city"
    case dashboardTapped = "dashboard_tapped"
    case dashboardClear = "dashboard_clear"
    case dashboardCloudy = "dashboard_cloudy"
    case dashboardRainy = "dashboard_rainy"
    case dashboardStormy = "dashboard_stormy"
    case dashboardSnowy = "dashboard_snowy"
    case dashboardAll = "dashboard_all"
    case changedBackground = "im_changed_background"
    case textColorTapped = "im_text_color_tapped"
    case textColorChanged = "im_text_color_changed"
    case textBrightnessChanged = "im_text_brightness_changed"
    case shadowsToggled = "im_shadows_toggled"
    case cameraTapped = "im_camera_tapped"
    case albumTapped = "im_album_tapped"
    case resetTapped = "im_reset_tapped"
    case blurChanged = "im_blur_changed"
    case brightnessChanged = "im_brightness_changed"
    case swipedPage = "swiped_page"
    case imageMenuTapped = "image_menu_tapped" // case screen from whence it came
}

/* Copyright (c) 2020 The Brave Authors. All rights reserved.
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this file,
 * You can obtain one at http://mozilla.org/MPL/2.0/. */

#include "base/feature_list.h"
#include "brave/components/brave_shields/common/brave_shield_constants.h"
#include "components/content_settings/core/common/content_settings.h"

#define BRAVE_GET_RENDER_CONTENT_SETTING_RULES                              \
  DCHECK(RendererContentSettingRules::IsRendererContentSetting(             \
      ContentSettingsType::AUTOPLAY));                                      \
  map->GetSettingsForOneType(ContentSettingsType::AUTOPLAY,                 \
                             &(rules->autoplay_rules));                     \
  DCHECK(RendererContentSettingRules::IsRendererContentSetting(             \
      ContentSettingsType::BRAVE_FINGERPRINTING_V2));                       \
  map->GetSettingsForOneType(ContentSettingsType::BRAVE_FINGERPRINTING_V2,  \
                             &(rules->fingerprinting_rules));               \
  DCHECK(RendererContentSettingRules::IsRendererContentSetting(             \
      ContentSettingsType::BRAVE_SHIELDS));                                 \
  map->GetSettingsForOneType(ContentSettingsType::BRAVE_SHIELDS,            \
                             &(rules->brave_shields_rules));                \
  DCHECK(RendererContentSettingRules::IsRendererContentSetting(             \
      ContentSettingsType::BRAVE_COSMETIC_FILTERING));                      \
  map->GetSettingsForOneType(ContentSettingsType::BRAVE_COSMETIC_FILTERING, \
                             &(rules->cosmetic_filtering_rules));

#include "src/components/content_settings/core/browser/content_settings_utils.cc"

#undef BRAVE_GET_RENDER_CONTENT_SETTING_RULES

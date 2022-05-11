/* Copyright (c) 2019 The Brave Authors. All rights reserved.
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this file,
 * You can obtain one at http://mozilla.org/MPL/2.0/. */

#include "bat/ads/internal/conversions/conversion_info.h"

namespace ads {

ConversionInfo::ConversionInfo() = default;

ConversionInfo::ConversionInfo(const ConversionInfo& info) = default;

ConversionInfo::~ConversionInfo() = default;

bool ConversionInfo::operator==(const ConversionInfo& rhs) const {
  return creative_set_id == rhs.creative_set_id && type == rhs.type &&
         url_pattern == rhs.url_pattern &&
         observation_window == rhs.observation_window &&
         advertiser_public_key == rhs.advertiser_public_key &&
         expire_at == rhs.expire_at;
}

bool ConversionInfo::operator!=(const ConversionInfo& rhs) const {
  return !(*this == rhs);
}

bool ConversionInfo::IsValid() const {
  if (creative_set_id.empty() || type.empty() || url_pattern.empty() ||
      expire_at.is_null()) {
    return false;
  }

  return true;
}

std::string ConversionsAsString(
    const std::vector<ConversionInfo>& conversions) {
  std::string result = "{";
  for (const auto& conversion : conversions) {
    result += conversion.creative_set_id;
    result += ",";
    result += conversion.type;
    result += ",";
    result += conversion.url_pattern;
    result += ";";
  }
  result += "}";
  return result;
}

}  // namespace ads

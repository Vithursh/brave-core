/* Copyright (c) 2022 The Brave Authors. All rights reserved.
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this file,
 * You can obtain one at http://mozilla.org/MPL/2.0/. */

#include "brave/ios/browser/api/url/url_spoof_checker.h"

#include "base/bind.h"
#include "base/callback.h"
#include "base/notreached.h"
#include "base/strings/sys_string_conversions.h"
#include "build/build_config.h"
#include "components/lookalikes/core/features.h"
#include "components/lookalikes/core/lookalike_url_ui_util.h"
#include "components/lookalikes/core/lookalike_url_util.h"
#include "components/reputation/core/safety_tips_config.h"
#include "components/url_formatter/elide_url.h"
#include "components/url_formatter/spoof_checks/top_domains/domains-trie-inc.cc"
#include "components/url_formatter/spoof_checks/top_domains/top_domain_util.h"
#include "components/url_formatter/url_formatter.h"
#include "net/base/mac/url_conversions.h"
#include "url/gurl.h"
#include "url/origin.h"

#if !defined(__has_feature) || !__has_feature(objc_arc)
#error "This file requires ARC support."
#endif

// MARK: - SkeletonType

BraveSpoofCheckerSkeletonType const BraveSpoofCheckerSkeletonTypeFull =
    static_cast<NSInteger>(url_formatter::SkeletonType::kFull);
BraveSpoofCheckerSkeletonType const
    BraveSpoofCheckerSkeletonTypeSeparatorsRemoved =
        static_cast<NSInteger>(url_formatter::SkeletonType::kSeparatorsRemoved);

// MARK: - LookalikeURLMatchType

BraveSpoofCheckerLookalikeURLMatchType const
    BraveSpoofCheckerLookalikeURLMatchTypeNone =
        static_cast<NSInteger>(LookalikeUrlMatchType::kNone);
BraveSpoofCheckerLookalikeURLMatchType const
    BraveSpoofCheckerLookalikeURLMatchTypeSiteEngagement =
        static_cast<NSInteger>(LookalikeUrlMatchType::kSiteEngagement);
BraveSpoofCheckerLookalikeURLMatchType const
    BraveSpoofCheckerLookalikeURLMatchTypeEditDistance =
        static_cast<NSInteger>(LookalikeUrlMatchType::kEditDistance);
BraveSpoofCheckerLookalikeURLMatchType const
    BraveSpoofCheckerLookalikeURLMatchTypeEditDistanceSiteEngagement =
        static_cast<NSInteger>(
            LookalikeUrlMatchType::kEditDistanceSiteEngagement);
BraveSpoofCheckerLookalikeURLMatchType const
    BraveSpoofCheckerLookalikeURLMatchTypeTargetEmbedding =
        static_cast<NSInteger>(LookalikeUrlMatchType::kTargetEmbedding);
BraveSpoofCheckerLookalikeURLMatchType const
    BraveSpoofCheckerLookalikeURLMatchTypeSkeletonMatchTop500 =
        static_cast<NSInteger>(LookalikeUrlMatchType::kSkeletonMatchTop500);
BraveSpoofCheckerLookalikeURLMatchType const
    BraveSpoofCheckerLookalikeURLMatchTypeSkeletonMatchTop5k =
        static_cast<NSInteger>(LookalikeUrlMatchType::kSkeletonMatchTop5k);
BraveSpoofCheckerLookalikeURLMatchType const
    BraveSpoofCheckerLookalikeURLMatchTypeTargetEmbeddingForSafetyTips =
        static_cast<NSInteger>(
            LookalikeUrlMatchType::kTargetEmbeddingForSafetyTips);
BraveSpoofCheckerLookalikeURLMatchType const
    BraveSpoofCheckerLookalikeURLMatchTypeFailedSpoofChecks =
        static_cast<NSInteger>(LookalikeUrlMatchType::kFailedSpoofChecks);
BraveSpoofCheckerLookalikeURLMatchType const
    BraveSpoofCheckerLookalikeURLMatchTypeCharacterSwapSiteEngagement =
        static_cast<NSInteger>(
            LookalikeUrlMatchType::kCharacterSwapSiteEngagement);
BraveSpoofCheckerLookalikeURLMatchType const
    BraveSpoofCheckerLookalikeURLMatchTypeCharacterSwapTop500 =
        static_cast<NSInteger>(LookalikeUrlMatchType::kCharacterSwapTop500);

// MARK: - Implementation

@implementation URLSpoofCheckerTopDomainEntry
- (instancetype)initWithEntry:(url_formatter::TopDomainEntry)entry {
  if ((self = [super init])) {
    _domain = base::SysUTF8ToNSString(entry.domain) ?: @"";
    _isTop500 = entry.is_top_500;
    _skeletonType = static_cast<BraveSpoofCheckerLookalikeURLMatchType>(
        entry.skeleton_type);
  }
  return self;
}
@end

@implementation BraveURLSpoofCheckerResult
- (instancetype)initWithMatchType:(LookalikeUrlMatchType)matchType
                     suggestedURL:(NSURL*)suggestedURL {
  if ((self = [super init])) {
    _urlMatchType =
        static_cast<BraveSpoofCheckerLookalikeURLMatchType>(matchType);
    _suggestedURL = suggestedURL;
  }
  return self;
}
@end

@implementation BraveURLSpoofChecker
+ (URLSpoofCheckerTopDomainEntry*)getSimilarTopDomain:(NSString*)hostname {
  url_formatter::TopDomainEntry entry =
      url_formatter::IDNSpoofChecker().GetSimilarTopDomain(
          base::SysNSStringToUTF16(hostname));
  return [[URLSpoofCheckerTopDomainEntry alloc] initWithEntry:entry];
}

+ (URLSpoofCheckerTopDomainEntry*)lookupSkeletonInTopDomains:
    (NSString*)hostname {
  url_formatter::TopDomainEntry entry =
      url_formatter::IDNSpoofChecker().LookupSkeletonInTopDomains(
          base::SysNSStringToUTF8(hostname));
  return [[URLSpoofCheckerTopDomainEntry alloc] initWithEntry:entry];
}

+ (NSArray<NSString*>*)getSkeletons:(NSString*)url {
  const url_formatter::IDNConversionResult result =
      url_formatter::UnsafeIDNToUnicodeWithDetails(
          GURL(base::SysNSStringToUTF8(url)).host());
  Skeletons skeletons =
      url_formatter::IDNSpoofChecker().GetSkeletons(result.result);

  NSMutableArray* array = [[NSMutableArray alloc] init];
  for (const auto& skeleton : skeletons) {
    NSString* result = base::SysUTF8ToNSString(skeleton);
    if (result) {
      [array addObject:result];
    }
  }
  return array;
}

+ (BraveURLSpoofCheckerResult*)isLookalikeURL:(NSString*)url {
  // See:
  // //ios/components/security_interstitials/lookalikes/lookalike_url_tab_helper.mm
  // For more info

  GURL response_url = GURL(base::SysNSStringToUTF8(url));
  // If the URL is not an HTTP or HTTPS page, don't show any warning.
  if (!response_url.SchemeIsHTTPOrHTTPS()) {
    return [[BraveURLSpoofCheckerResult alloc]
        initWithMatchType:LookalikeUrlMatchType::kNone
             suggestedURL:nil];
  }

  // Fetch the component allowlist.
  const auto* proto = reputation::GetSafetyTipsRemoteConfigProto();
  // When there's no proto (like at browser start), fail-safe and don't block.
  if (!proto) {
    return [[BraveURLSpoofCheckerResult alloc]
        initWithMatchType:LookalikeUrlMatchType::kNone
             suggestedURL:nil];
  }

  // If the URL is in the component updater allowlist, don't show any warning.
  if (reputation::IsUrlAllowlistedBySafetyTipsComponent(
          proto, response_url.GetWithEmptyPath())) {
    return [[BraveURLSpoofCheckerResult alloc]
        initWithMatchType:LookalikeUrlMatchType::kNone
             suggestedURL:nil];
  }

  const DomainInfo navigated_domain = GetDomainInfo(response_url);
  // Empty domain_and_registry happens on private domains.
  if (navigated_domain.domain_and_registry.empty() ||
      IsTopDomain(navigated_domain)) {
    return [[BraveURLSpoofCheckerResult alloc]
        initWithMatchType:LookalikeUrlMatchType::kNone
             suggestedURL:nil];
  }

  std::vector<DomainInfo> engaged_sites;
  std::string matched_domain;
  LookalikeUrlMatchType match_type = LookalikeUrlMatchType::kNone;
  // Target allowlist is not currently used in ios.
  const LookalikeTargetAllowlistChecker in_target_allowlist =
      base::BindRepeating(^(const std::string& hostname) {
        return false;
      });
  if (!GetMatchingDomain(navigated_domain, engaged_sites, in_target_allowlist,
                         proto, &matched_domain, &match_type)) {
    if (ShouldBlockBySpoofCheckResult(navigated_domain)) {
      return [[BraveURLSpoofCheckerResult alloc]
          initWithMatchType:LookalikeUrlMatchType::kFailedSpoofChecks
               suggestedURL:nil];
    }

    return [[BraveURLSpoofCheckerResult alloc]
        initWithMatchType:LookalikeUrlMatchType::kNone
             suggestedURL:nil];
  }
  DCHECK(!matched_domain.empty());

  if (ShouldBlockLookalikeUrlNavigation(match_type)) {
    const std::string suggested_domain = GetETLDPlusOne(matched_domain);
    DCHECK(!suggested_domain.empty());
    GURL::Replacements replace_host;
    replace_host.SetHostStr(suggested_domain);
    const GURL suggested_url =
        response_url.ReplaceComponents(replace_host).GetWithEmptyPath();
    return [[BraveURLSpoofCheckerResult alloc]
        initWithMatchType:match_type
             suggestedURL:net::NSURLWithGURL(suggested_url)];
  }
  return [[BraveURLSpoofCheckerResult alloc]
      initWithMatchType:LookalikeUrlMatchType::kNone
           suggestedURL:nil];
}
@end

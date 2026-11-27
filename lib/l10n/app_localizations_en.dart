// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get brandName => 'Bende Var';

  @override
  String get slogan => 'Your need, in your community.';

  @override
  String get welcomeTitle => 'Those who have, share.\nThose in need, find.';

  @override
  String get welcomeSubtitle =>
      'Sign in with your school email, your campus is waiting.';

  @override
  String get login => 'Sign in';

  @override
  String get signup => 'Sign up';

  @override
  String get loginTitle => 'Welcome back';

  @override
  String get loginSubtitle =>
      'Continue with your institutional email and password.';

  @override
  String get emailLabel => 'Institutional email';

  @override
  String get emailHint => 'name.surname@school.edu.tr';

  @override
  String get passwordLabel => 'Password';

  @override
  String get passwordHint => 'Enter your password';

  @override
  String get forgotPassword => 'Forgot my password';

  @override
  String get noAccount => 'Don\'t have an account?';

  @override
  String get showPassword => 'Show password';

  @override
  String get hidePassword => 'Hide password';

  @override
  String get back => 'Back';

  @override
  String get close => 'Close';

  @override
  String get cancel => 'Cancel';

  @override
  String get more => 'More';

  @override
  String get errorEmailEmpty => 'Enter your email address.';

  @override
  String get errorEmailNotEdu =>
      'Sign in with your institutional email (an address ending in .edu.tr).';

  @override
  String get errorPasswordEmpty => 'Enter your password.';

  @override
  String get emailHintShort => 'name.surname@school';

  @override
  String get errorAccountNotFound =>
      'We couldn\'t find an account with this email. Check it or sign up.';

  @override
  String get errorPasswordWrong => 'Wrong password. Try again.';

  @override
  String get errorTooManyAttempts =>
      'Too many failed attempts. Wait a bit and try again.';

  @override
  String get errorNotVerified =>
      'Your account isn\'t verified yet. Tap the link we emailed you.';

  @override
  String get resendVerification => 'Resend the link';

  @override
  String get verificationSent => 'Verification link sent.';

  @override
  String get navHome => 'Home';

  @override
  String get navMessages => 'Messages';

  @override
  String get navCreate => 'Create a listing or need';

  @override
  String get navNotifications => 'Notifications';

  @override
  String get navProfile => 'Profile';

  @override
  String get communityLabel => 'Community';

  @override
  String get searchHint => 'What are you looking for? Item or product...';

  @override
  String get voiceSearch => 'Voice search';

  @override
  String get filters => 'Filters';

  @override
  String tabListings(int n) {
    return 'Listings · $n';
  }

  @override
  String tabNeeds(int n) {
    return 'Needs · $n';
  }

  @override
  String countListings(int n) {
    return '$n listings';
  }

  @override
  String countNeeds(int n) {
    return '$n needs';
  }

  @override
  String get sortNewest => 'Newest';

  @override
  String get sortOldest => 'Oldest';

  @override
  String get emptyResults => 'No results found.';

  @override
  String get emptyFavorites => 'You have no favorites yet.';

  @override
  String get showFavorites => 'Show favorites';

  @override
  String get showAll => 'Show all';

  @override
  String get favoriteAdd => 'Add to favorites';

  @override
  String get favoriteRemove => 'Remove from favorites';

  @override
  String get respondHaveIt => 'I have it';

  @override
  String get comingSoonTitle => 'Coming soon';

  @override
  String get comingSoonBody => 'This feature isn\'t ready yet.';

  @override
  String get comingSoonSnack => 'This feature is coming soon.';

  @override
  String get categoryBook => 'Textbook';

  @override
  String get categoryElectronics => 'Electronics';

  @override
  String get categoryDorm => 'Dorm items';

  @override
  String get categorySports => 'Sports';

  @override
  String get conditionNew => 'New';

  @override
  String get conditionLightlyUsed => 'Lightly used';

  @override
  String get conditionUsed => 'Used';

  @override
  String get modeLend => 'Loan';

  @override
  String get modeSell => 'For sale';

  @override
  String get priceFree => 'Free';

  @override
  String get pricePaid => 'Paid';

  @override
  String get priceDaily => 'Daily';

  @override
  String get priceTotal => 'Total';

  @override
  String get priceHint => 'Amount (₺)';

  @override
  String get urgencyUrgent => 'Urgent';

  @override
  String get urgencyThisWeek => 'This week';

  @override
  String get urgencyFlexible => 'Flexible';

  @override
  String get detailTitleListing => 'Listing details';

  @override
  String get detailTitleNeed => 'Need details';

  @override
  String get badgeIlan => 'LISTING';

  @override
  String get badgeNeed => 'NEED';

  @override
  String get badgeIlanLarge => 'LISTING · I HAVE IT';

  @override
  String get badgeNeedLarge => 'NEED · I NEED IT';

  @override
  String get statusPublished => 'LIVE';

  @override
  String get statusPublishedShort => 'Live';

  @override
  String get rowCategory => 'Category';

  @override
  String get rowCondition => 'Condition';

  @override
  String get rowMode => 'Type';

  @override
  String get rowPrice => 'Price';

  @override
  String get rowAvailable => 'Available';

  @override
  String get rowNeededWhen => 'Needed';

  @override
  String get rowUrgency => 'Urgency';

  @override
  String get rowCommunity => 'Community';

  @override
  String get favorite => 'Favorite';

  @override
  String get favorited => 'In favorites';

  @override
  String get actionBorrow => 'Request loan';

  @override
  String get actionBuy => 'Buy';

  @override
  String get share => 'Share';

  @override
  String get createIlanTitle => 'I have it';

  @override
  String get createIlanSubtitle => 'Lend an item you have';

  @override
  String get createNeedTitle => 'I need it';

  @override
  String get createNeedSubtitle => 'Borrow an item you\'re looking for';

  @override
  String get newListingTitle => 'New listing';

  @override
  String get newNeedTitle => 'New need';

  @override
  String get sectionItem => 'Item details';

  @override
  String get sectionTerms => 'Loan terms';

  @override
  String get fieldPhotos => 'Photos *';

  @override
  String get photoAdd => 'Add';

  @override
  String get fieldTitle => 'Item name *';

  @override
  String get fieldCategory => 'Category *';

  @override
  String get fieldCondition => 'Condition *';

  @override
  String get fieldDescription => 'Description';

  @override
  String get fieldAvailability => 'Availability dates *';

  @override
  String get fieldNeededWhen => 'When do you need it? *';

  @override
  String get fieldMode => 'Type';

  @override
  String get fieldUrgency => 'Urgency *';

  @override
  String get fieldPrice => 'Price *';

  @override
  String get datePick => 'Pick a date';

  @override
  String get errorRequired => 'This field can\'t be empty.';

  @override
  String get errorChoose => 'Choose an option.';

  @override
  String get errorDates =>
      'Pick a start and an end date; the end can\'t be before the start.';

  @override
  String get errorPrice => 'Enter a valid amount.';

  @override
  String get publish => 'Publish';

  @override
  String get publishedTitleListing => 'Your listing is live';

  @override
  String get publishedBodyListing =>
      'Your listing appears in the Listings tab of the selected communities. You\'ll get a notification when someone says \"I need it\".';

  @override
  String get publishedTitleNeed => 'Your need is live';

  @override
  String get publishedBodyNeed =>
      'Your need appears in the Needs tab of your community. You\'ll get a notification when someone says \"I have it\".';

  @override
  String get view => 'View';

  @override
  String get backToHome => 'Back to home';

  @override
  String get messagesTitle => 'Messages';

  @override
  String get filterAll => 'All';

  @override
  String get filterUnread => 'Unread';

  @override
  String get filterActive => 'Active';

  @override
  String get filterPast => 'Past';

  @override
  String get emptyMessages => 'You have no messages yet.';

  @override
  String get respondedNeedIt => 'said “I need it”';

  @override
  String get respondedHaveIt => 'said “I have it”';

  @override
  String get bubbleNeedIt => 'I need it';

  @override
  String get bubbleHaveIt => 'I have it';

  @override
  String get accepted => 'Accepted';

  @override
  String get agreementSummary => 'Agreement summary';

  @override
  String get agreementDetail => 'Agreement details';

  @override
  String get messageHint => 'Write a message';

  @override
  String get send => 'Send';

  @override
  String get sendMessage => 'Send message';

  @override
  String get notificationsTitle => 'Notifications';

  @override
  String get markAllRead => 'Mark all as read';

  @override
  String get sectionUpcomingReturns => 'Upcoming returns';

  @override
  String get sectionToday => 'Today';

  @override
  String get sectionThisWeek => 'This week';

  @override
  String daysLate(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n days late',
      one: '1 day late',
    );
    return '$_temp0';
  }

  @override
  String get tomorrow => 'Tomorrow';

  @override
  String notifOverdueBody(String name) {
    return 'You were supposed to return it to $name.';
  }

  @override
  String notifDueSoonBody(String name) {
    return '$name will return it to you.';
  }

  @override
  String get actionReturned => 'I returned it';

  @override
  String get actionMessage => 'Send a message';

  @override
  String notifResponseRest(String item) {
    return 'said “I need it” on your listing “$item”';
  }

  @override
  String notifMessageRest(String text) {
    return 'sent a message: “$text”';
  }

  @override
  String notifAcceptedRest(String item) {
    return 'accepted your need for “$item”';
  }

  @override
  String get emptyNotifications => 'You have no new notifications.';

  @override
  String get profileTitle => 'Profile';

  @override
  String get settings => 'Settings';

  @override
  String get edit => 'Edit';

  @override
  String get statRating => 'Rating';

  @override
  String get statTransactions => 'Deals';

  @override
  String get statOnTime => 'On time';

  @override
  String get sectionPending => 'Pending';

  @override
  String pendingNewResponses(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n new responses',
      one: '1 new response',
    );
    return '$_temp0';
  }

  @override
  String get pendingHandover => 'Pick up';

  @override
  String get loansTitle => 'My loans';

  @override
  String get borrowed => 'Borrowed';

  @override
  String get lent => 'Lent';

  @override
  String get myListingsAndNeeds => 'My needs and listings';

  @override
  String get themeAndLanguage => 'Theme and language';

  @override
  String get logout => 'Sign out';

  @override
  String get logoutTitle => 'Do you want to sign out?';

  @override
  String get logoutLine1 => 'Your session on this phone will end.';

  @override
  String get logoutLine2 =>
      'You\'ll need your institutional email and password to sign in again.';

  @override
  String get logoutLine3 =>
      'This phone won\'t get notifications, and return reminders will stop too.';

  @override
  String get statusOnLoan => 'On loan';

  @override
  String get statusAwaiting => 'Awaiting handover';

  @override
  String get statusReturned => 'Returned';

  @override
  String get actionReturn => 'Return';

  @override
  String get actionEarlyReturn => 'Return early';

  @override
  String get actionScanQr => 'Scan QR';

  @override
  String get actionShowQr => 'Show QR';

  @override
  String get qrScan => 'Scan QR code';

  @override
  String get sheetTitle => 'Appearance and language';

  @override
  String get themeHeading => 'Theme';

  @override
  String get themeSystem => 'System';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get languageHeading => 'Language';

  @override
  String get languageSystem => 'System';

  @override
  String get languageTr => 'Türkçe';

  @override
  String get languageEn => 'English';

  @override
  String get timeNow => 'Just now';

  @override
  String timeMinutesAgo(int n) {
    return '$n min ago';
  }

  @override
  String timeHoursAgo(int n) {
    return '$n h ago';
  }

  @override
  String timeDaysAgo(int n) {
    return '$n days ago';
  }

  @override
  String get timeYesterday => 'Yesterday';

  @override
  String get signupTitle => 'Start with your school email';

  @override
  String get signupSubtitle =>
      'We find your community from your email domain. We\'ll send you a verification link.';

  @override
  String get signupExit => 'Leave sign-up';

  @override
  String get stepAccount => 'Account';

  @override
  String get stepVerify => 'Verification';

  @override
  String get stepName => 'Your name';

  @override
  String get signupJoinCommunity => 'You\'ll join your school community';

  @override
  String get signupNewCommunity =>
      'Your community will be opened with this first sign-up';

  @override
  String get signupPasswordHint => 'Create a password';

  @override
  String get signupPasswordRule =>
      'At least 8 characters, with at least one letter and one digit.';

  @override
  String get errorPasswordWeak =>
      'Your password needs at least 8 characters, one letter and one digit.';

  @override
  String get errorTermsRequired => 'Accept the terms to continue.';

  @override
  String get errorEmailInUse =>
      'This email is already registered. Try signing in.';

  @override
  String get termsLead => 'I have read and accept the ';

  @override
  String get termsLink => 'Terms of Use';

  @override
  String get termsMid => ' and ';

  @override
  String get privacyLink => 'Privacy Policy';

  @override
  String get termsTail => '.';

  @override
  String get haveAccount => 'Already have an account?';

  @override
  String get sentTitle => 'We sent the link';

  @override
  String get sentSubtitle => 'We sent the verification link to this address:';

  @override
  String get sentInstruction =>
      'Tap the link in your school email, then come back and press \"I tapped the link\". The link is valid for 24 hours.';

  @override
  String get sentWaiting => 'Waiting for verification';

  @override
  String get openMailApp => 'Open mail app';

  @override
  String get clickedLink => 'I tapped the link';

  @override
  String resendIn(String time) {
    return 'Resend ($time)';
  }

  @override
  String get resendLink => 'Resend';

  @override
  String get fixEmail => 'Fix the email';

  @override
  String get notVerifiedYet =>
      'Your email isn\'t verified yet. Make sure you tapped the link.';

  @override
  String get linkResent => 'Link sent again.';

  @override
  String get nameTitle => 'What\'s your name?';

  @override
  String get nameSubtitle =>
      'Other users will see you with this name. You can edit it.';

  @override
  String get nameLabel => 'Full name';

  @override
  String get nameHint => 'Enter your first and last name';

  @override
  String get errorNameEmpty => 'Enter your name.';

  @override
  String get finish => 'Finish';

  @override
  String get expiredTitle => 'The link has expired';

  @override
  String get expiredBody =>
      'The verification link was valid for 24 hours. We can send you a new one.';

  @override
  String get sendNewLink => 'Send a new link';

  @override
  String get legalTermsTitle => 'Terms of Use';

  @override
  String get legalPrivacyTitle => 'Privacy Policy';

  @override
  String get legalTermsBody =>
      'Bende Var is a community app where people in the same school or dorm meet each other\'s needs by lending and borrowing.\n\n1. Account\nYou sign up with your institutional email and join your school\'s community. You are responsible for your account\'s security.\n\n2. Listings and needs\nListings are for lending your items, needs are for looking for an item. The information you share must be accurate.\n\n3. Borrowing and lending\nThe parties agree on the handover place, duration and conditions by messaging. No payments are taken in the app. The borrower is responsible for returning the item on time and in the condition received.\n\n4. Conduct\nYou treat other users with respect. You may not share illegal, dangerous or other people\'s items.\n\n5. Closing accounts\nAccounts that violate these terms may be closed.\n\nThis text is a placeholder and not the final legal text.';

  @override
  String get legalPrivacyBody =>
      'This policy explains what information Bende Var uses and why.\n\n1. Information we collect\nYour institutional email address, your name, the listings and needs you share, your messages and ratings.\n\n2. How we use it\nTo match you with your school\'s community, run borrowing and lending, send return reminders and improve the app.\n\n3. Sharing\nYour name and listings are visible only to users in your community. We don\'t sell your information to third parties.\n\n4. Retention and deletion\nYour personal information is deleted when you close your account.\n\n5. Your rights\nYou can ask to access, correct or delete your information.\n\nThis text is a placeholder and not the final legal text.';

  @override
  String get forgotTitle => 'Forgot your password?';

  @override
  String get forgotSubtitle =>
      'Enter your institutional email and we\'ll send you a link to reset your password.';

  @override
  String get sendResetLink => 'Send link';

  @override
  String get resetSentSubtitle =>
      'We sent the password reset link to this address:';

  @override
  String get resetSentInstruction =>
      'Tap the link in your email, then come back and press \"I tapped the link\". The link is valid for 24 hours.';

  @override
  String get resetExpired => 'The link has expired. Request a new one.';

  @override
  String get newPasswordTitle => 'Set a new password';

  @override
  String get newPasswordSubtitle => 'Choose a new password for your account.';

  @override
  String get newPasswordLabel => 'New password';

  @override
  String get newPasswordHint => 'Enter your new password';

  @override
  String get confirmPasswordLabel => 'Repeat the new password';

  @override
  String get confirmPasswordHint => 'Type your password again';

  @override
  String get errorPasswordMismatch => 'Passwords don\'t match.';

  @override
  String get savePassword => 'Save password';

  @override
  String get passwordUpdated =>
      'Your password is updated. You can sign in with it.';

  @override
  String get myCommunities => 'My communities';

  @override
  String get notificationSettings => 'Notification settings';

  @override
  String get privacySupport => 'Privacy and support';

  @override
  String get notifMessages => 'Messages';

  @override
  String get notifMessagesDesc => 'Notify me when a new message arrives.';

  @override
  String get notifResponses => 'Responses';

  @override
  String get notifResponsesDesc =>
      'Notify me when someone responds to my listing or need.';

  @override
  String get notifReminders => 'Return reminders';

  @override
  String get notifRemindersDesc =>
      'Notify me when the return day of an item I borrowed is near.';

  @override
  String get notifAnnouncements => 'Community announcements';

  @override
  String get notifAnnouncementsDesc =>
      'Notify me about important news in my community.';

  @override
  String get blockedAccounts => 'Blocked accounts';

  @override
  String get helpSupport => 'Help and support';

  @override
  String get blockedEmpty => 'You haven\'t blocked anyone.';

  @override
  String get unblock => 'Unblock';

  @override
  String get unblockTitle => 'Do you want to unblock?';

  @override
  String unblockLine1(String name) {
    return '$name can message you again.';
  }

  @override
  String get unblockLine2 => 'You\'ll see their listings and needs again.';

  @override
  String get unblocked => 'Unblocked.';

  @override
  String get communitiesSearchHint => 'Search communities';

  @override
  String get communitiesMine => 'My communities';

  @override
  String get communitiesResults => 'Search results';

  @override
  String get communitiesNoResults => 'No community matches this search.';

  @override
  String communityMembers(int count) {
    return '$count members';
  }

  @override
  String get communitySchoolBadge => 'Your school';

  @override
  String get communityFounderBadge => 'Founder';

  @override
  String get communityJoin => 'Join';

  @override
  String get communityMember => 'Member';

  @override
  String get communityJoined => 'You joined the community.';

  @override
  String get communityLeave => 'Leave';

  @override
  String get joinWithCode => 'Join with invite code';

  @override
  String get createCommunity => 'Create community';

  @override
  String get inviteCodeTitle => 'Join with invite code';

  @override
  String get inviteCodeHint => 'Invite code';

  @override
  String get inviteCodeBody =>
      'Enter the code you got from the community\'s founder.';

  @override
  String get inviteCodeInvalid =>
      'This code isn\'t valid. Check it and try again.';

  @override
  String get inviteCodeAlready => 'You\'re already a member of this community.';

  @override
  String get inviteCodeSuccessTitle => 'You joined the community';

  @override
  String inviteCodeSuccessBody(String name) {
    return 'You joined $name.';
  }

  @override
  String get done => 'Done';

  @override
  String get createCommunityTitle => 'Create community';

  @override
  String get communityNameLabel => 'Community name';

  @override
  String get communityNameHint => 'E.g. Camping Club';

  @override
  String get communityNameError =>
      'The community name must be at least 3 characters.';

  @override
  String get communityDescLabel => 'Description (optional)';

  @override
  String get communityDescHint => 'What is this community for?';

  @override
  String get communityVisibilityLabel => 'Visibility';

  @override
  String get visibilityOpen => 'Open';

  @override
  String get visibilityOpenDesc => 'Shows up in search, anyone can join.';

  @override
  String get visibilitySchool => 'School only';

  @override
  String get visibilitySchoolDesc =>
      'Shows up in search only for school members, and only they can join.';

  @override
  String get visibilitySecret => 'Secret';

  @override
  String get visibilitySecretDesc =>
      'Doesn\'t show up in search; joined only with an invite code.';

  @override
  String get communityCreated => 'Community created.';

  @override
  String get founderActionsTitle => 'Community actions';

  @override
  String get copyInviteCode => 'Copy invite code';

  @override
  String get inviteCodeCopied => 'Invite code copied.';

  @override
  String get deleteCommunity => 'Delete community';

  @override
  String get deleteCommunityTitle => 'Do you want to delete the community?';

  @override
  String deleteCommunityLine1(String name) {
    return '$name and its memberships will be deleted permanently.';
  }

  @override
  String get deleteCommunityLine2 => 'This can\'t be undone.';

  @override
  String get communityDeleted => 'Community deleted.';

  @override
  String get leaveCommunityTitle => 'Do you want to leave the community?';

  @override
  String leaveCommunityLine1(String name) {
    return 'If you leave $name, you won\'t see your listings and needs there.';
  }

  @override
  String get leaveCommunityLine2 => 'You can join again later.';

  @override
  String get communityLeft => 'You left the community.';
}

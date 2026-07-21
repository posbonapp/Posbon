import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_ru.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('fr'),
    Locale('ru'),
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Posbon'**
  String get appName;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get signIn;

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get signUp;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get fullName;

  /// No description provided for @buildingName.
  ///
  /// In en, this message translates to:
  /// **'Building name'**
  String get buildingName;

  /// No description provided for @address.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get address;

  /// No description provided for @apartments.
  ///
  /// In en, this message translates to:
  /// **'Apartments'**
  String get apartments;

  /// No description provided for @parkingSpots.
  ///
  /// In en, this message translates to:
  /// **'Parking spots'**
  String get parkingSpots;

  /// No description provided for @entrances.
  ///
  /// In en, this message translates to:
  /// **'Entrances'**
  String get entrances;

  /// No description provided for @floors.
  ///
  /// In en, this message translates to:
  /// **'Floors'**
  String get floors;

  /// No description provided for @createBuilding.
  ///
  /// In en, this message translates to:
  /// **'Create building'**
  String get createBuilding;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @haveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get haveAccount;

  /// No description provided for @noAccount.
  ///
  /// In en, this message translates to:
  /// **'No account yet?'**
  String get noAccount;

  /// No description provided for @errorGeneric.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get errorGeneric;

  /// No description provided for @tasks.
  ///
  /// In en, this message translates to:
  /// **'Tasks'**
  String get tasks;

  /// No description provided for @newTask.
  ///
  /// In en, this message translates to:
  /// **'New task'**
  String get newTask;

  /// No description provided for @taskTitle.
  ///
  /// In en, this message translates to:
  /// **'Task title'**
  String get taskTitle;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @assignTo.
  ///
  /// In en, this message translates to:
  /// **'Assign to'**
  String get assignTo;

  /// No description provided for @apartment.
  ///
  /// In en, this message translates to:
  /// **'Apartment'**
  String get apartment;

  /// No description provided for @wholeBuilding.
  ///
  /// In en, this message translates to:
  /// **'Whole building'**
  String get wholeBuilding;

  /// No description provided for @urgent.
  ///
  /// In en, this message translates to:
  /// **'Urgent'**
  String get urgent;

  /// No description provided for @create.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get create;

  /// No description provided for @statusNew.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get statusNew;

  /// No description provided for @statusReview.
  ///
  /// In en, this message translates to:
  /// **'Review'**
  String get statusReview;

  /// No description provided for @statusDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get statusDone;

  /// No description provided for @statusRedo.
  ///
  /// In en, this message translates to:
  /// **'Redo'**
  String get statusRedo;

  /// No description provided for @noTasks.
  ///
  /// In en, this message translates to:
  /// **'No tasks yet'**
  String get noTasks;

  /// No description provided for @people.
  ///
  /// In en, this message translates to:
  /// **'People'**
  String get people;

  /// No description provided for @addWorker.
  ///
  /// In en, this message translates to:
  /// **'Add worker'**
  String get addWorker;

  /// No description provided for @workers.
  ///
  /// In en, this message translates to:
  /// **'Workers'**
  String get workers;

  /// No description provided for @myTasks.
  ///
  /// In en, this message translates to:
  /// **'My tasks'**
  String get myTasks;

  /// No description provided for @toDo.
  ///
  /// In en, this message translates to:
  /// **'To do'**
  String get toDo;

  /// No description provided for @waitingReview.
  ///
  /// In en, this message translates to:
  /// **'Waiting for review'**
  String get waitingReview;

  /// No description provided for @returned.
  ///
  /// In en, this message translates to:
  /// **'Returned'**
  String get returned;

  /// No description provided for @submitWork.
  ///
  /// In en, this message translates to:
  /// **'Submit work'**
  String get submitWork;

  /// No description provided for @takePhoto.
  ///
  /// In en, this message translates to:
  /// **'Take photo'**
  String get takePhoto;

  /// No description provided for @photoRequired.
  ///
  /// In en, this message translates to:
  /// **'Photo is required'**
  String get photoRequired;

  /// No description provided for @accept.
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get accept;

  /// No description provided for @redo.
  ///
  /// In en, this message translates to:
  /// **'Redo'**
  String get redo;

  /// No description provided for @adminComment.
  ///
  /// In en, this message translates to:
  /// **'Comment for worker'**
  String get adminComment;

  /// No description provided for @review.
  ///
  /// In en, this message translates to:
  /// **'Review'**
  String get review;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @deleteTaskConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete this task?'**
  String get deleteTaskConfirm;

  /// No description provided for @created.
  ///
  /// In en, this message translates to:
  /// **'Created'**
  String get created;

  /// No description provided for @submitted.
  ///
  /// In en, this message translates to:
  /// **'Submitted'**
  String get submitted;

  /// No description provided for @accepted.
  ///
  /// In en, this message translates to:
  /// **'Accepted'**
  String get accepted;

  /// No description provided for @stock.
  ///
  /// In en, this message translates to:
  /// **'Stock'**
  String get stock;

  /// No description provided for @items.
  ///
  /// In en, this message translates to:
  /// **'Items'**
  String get items;

  /// No description provided for @newItem.
  ///
  /// In en, this message translates to:
  /// **'New item'**
  String get newItem;

  /// No description provided for @itemName.
  ///
  /// In en, this message translates to:
  /// **'Item name'**
  String get itemName;

  /// No description provided for @icon.
  ///
  /// In en, this message translates to:
  /// **'Icon'**
  String get icon;

  /// No description provided for @minStock.
  ///
  /// In en, this message translates to:
  /// **'Minimum stock'**
  String get minStock;

  /// No description provided for @inStock.
  ///
  /// In en, this message translates to:
  /// **'In stock'**
  String get inStock;

  /// No description provided for @reserved.
  ///
  /// In en, this message translates to:
  /// **'Reserved'**
  String get reserved;

  /// No description provided for @installed.
  ///
  /// In en, this message translates to:
  /// **'Installed'**
  String get installed;

  /// No description provided for @lowStock.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get lowStock;

  /// No description provided for @addStock.
  ///
  /// In en, this message translates to:
  /// **'Add to stock'**
  String get addStock;

  /// No description provided for @quantity.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get quantity;

  /// No description provided for @history.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get history;

  /// No description provided for @installHistory.
  ///
  /// In en, this message translates to:
  /// **'Installation history'**
  String get installHistory;

  /// No description provided for @noItems.
  ///
  /// In en, this message translates to:
  /// **'No items yet'**
  String get noItems;

  /// No description provided for @linkItem.
  ///
  /// In en, this message translates to:
  /// **'Item from stock'**
  String get linkItem;

  /// No description provided for @none.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get none;

  /// No description provided for @installedBy.
  ///
  /// In en, this message translates to:
  /// **'Installed by'**
  String get installedBy;

  /// No description provided for @noHistory.
  ///
  /// In en, this message translates to:
  /// **'No history yet'**
  String get noHistory;

  /// No description provided for @apartmentsTab.
  ///
  /// In en, this message translates to:
  /// **'Apartments'**
  String get apartmentsTab;

  /// No description provided for @addTenant.
  ///
  /// In en, this message translates to:
  /// **'Add tenant'**
  String get addTenant;

  /// No description provided for @tenant.
  ///
  /// In en, this message translates to:
  /// **'Tenant'**
  String get tenant;

  /// No description provided for @noTenant.
  ///
  /// In en, this message translates to:
  /// **'Empty'**
  String get noTenant;

  /// No description provided for @newPassword.
  ///
  /// In en, this message translates to:
  /// **'New password'**
  String get newPassword;

  /// No description provided for @credentials.
  ///
  /// In en, this message translates to:
  /// **'Login details'**
  String get credentials;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @copy.
  ///
  /// In en, this message translates to:
  /// **'Copied'**
  String get copy;

  /// No description provided for @myRequests.
  ///
  /// In en, this message translates to:
  /// **'My requests'**
  String get myRequests;

  /// No description provided for @newRequest.
  ///
  /// In en, this message translates to:
  /// **'Report a problem'**
  String get newRequest;

  /// No description provided for @whatHappened.
  ///
  /// In en, this message translates to:
  /// **'What happened?'**
  String get whatHappened;

  /// No description provided for @sendRequest.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get sendRequest;

  /// No description provided for @myApartment.
  ///
  /// In en, this message translates to:
  /// **'My apartment'**
  String get myApartment;

  /// No description provided for @callDispatcher.
  ///
  /// In en, this message translates to:
  /// **'Call dispatcher'**
  String get callDispatcher;

  /// No description provided for @rateWork.
  ///
  /// In en, this message translates to:
  /// **'Rate'**
  String get rateWork;

  /// No description provided for @requestNew.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get requestNew;

  /// No description provided for @requestInProgress.
  ///
  /// In en, this message translates to:
  /// **'In progress'**
  String get requestInProgress;

  /// No description provided for @requestDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get requestDone;

  /// No description provided for @noRequests.
  ///
  /// In en, this message translates to:
  /// **'No requests yet'**
  String get noRequests;

  /// No description provided for @myHistory.
  ///
  /// In en, this message translates to:
  /// **'My apartment history'**
  String get myHistory;

  /// No description provided for @requests.
  ///
  /// In en, this message translates to:
  /// **'Requests'**
  String get requests;

  /// No description provided for @fromApartment.
  ///
  /// In en, this message translates to:
  /// **'From apartment'**
  String get fromApartment;

  /// No description provided for @createTaskFromRequest.
  ///
  /// In en, this message translates to:
  /// **'Create task'**
  String get createTaskFromRequest;

  /// No description provided for @closeRequest.
  ///
  /// In en, this message translates to:
  /// **'Close request'**
  String get closeRequest;

  /// No description provided for @requestDetails.
  ///
  /// In en, this message translates to:
  /// **'Request'**
  String get requestDetails;

  /// No description provided for @showOriginal.
  ///
  /// In en, this message translates to:
  /// **'Show original'**
  String get showOriginal;

  /// No description provided for @showTranslation.
  ///
  /// In en, this message translates to:
  /// **'Show translation'**
  String get showTranslation;

  /// No description provided for @linkedTask.
  ///
  /// In en, this message translates to:
  /// **'Linked task'**
  String get linkedTask;

  /// No description provided for @rating.
  ///
  /// In en, this message translates to:
  /// **'Rating'**
  String get rating;

  /// No description provided for @parking.
  ///
  /// In en, this message translates to:
  /// **'Parking'**
  String get parking;

  /// No description provided for @free.
  ///
  /// In en, this message translates to:
  /// **'Free'**
  String get free;

  /// No description provided for @occupied.
  ///
  /// In en, this message translates to:
  /// **'Occupied'**
  String get occupied;

  /// No description provided for @guest.
  ///
  /// In en, this message translates to:
  /// **'Guest'**
  String get guest;

  /// No description provided for @spot.
  ///
  /// In en, this message translates to:
  /// **'Spot'**
  String get spot;

  /// No description provided for @assignToApartment.
  ///
  /// In en, this message translates to:
  /// **'Assign to apartment'**
  String get assignToApartment;

  /// No description provided for @makeGuest.
  ///
  /// In en, this message translates to:
  /// **'Make guest spot'**
  String get makeGuest;

  /// No description provided for @release.
  ///
  /// In en, this message translates to:
  /// **'Release'**
  String get release;

  /// No description provided for @selectApartment.
  ///
  /// In en, this message translates to:
  /// **'Select apartment'**
  String get selectApartment;

  /// No description provided for @phone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phone;

  /// No description provided for @savePasswordWarning.
  ///
  /// In en, this message translates to:
  /// **'Save or print — the password won\'t be shown again.'**
  String get savePasswordWarning;

  /// No description provided for @daysAgo.
  ///
  /// In en, this message translates to:
  /// **'{days} days ago'**
  String daysAgo(int days);

  /// No description provided for @noPhone.
  ///
  /// In en, this message translates to:
  /// **'Phone number not set'**
  String get noPhone;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @buildingSettings.
  ///
  /// In en, this message translates to:
  /// **'Building settings'**
  String get buildingSettings;

  /// No description provided for @dispatcherPhone.
  ///
  /// In en, this message translates to:
  /// **'Dispatcher phone'**
  String get dispatcherPhone;

  /// No description provided for @structure.
  ///
  /// In en, this message translates to:
  /// **'Building structure'**
  String get structure;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get signOut;

  /// No description provided for @pushNotifications.
  ///
  /// In en, this message translates to:
  /// **'Push notifications'**
  String get pushNotifications;

  /// No description provided for @systemLanguage.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get systemLanguage;

  /// No description provided for @changePassword.
  ///
  /// In en, this message translates to:
  /// **'Change password'**
  String get changePassword;

  /// No description provided for @saved.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get saved;

  /// No description provided for @announcements.
  ///
  /// In en, this message translates to:
  /// **'Announcements'**
  String get announcements;

  /// No description provided for @newAnnouncement.
  ///
  /// In en, this message translates to:
  /// **'New announcement'**
  String get newAnnouncement;

  /// No description provided for @announcementTitle.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get announcementTitle;

  /// No description provided for @announcementBody.
  ///
  /// In en, this message translates to:
  /// **'Message'**
  String get announcementBody;

  /// No description provided for @sendToAll.
  ///
  /// In en, this message translates to:
  /// **'Send to all residents'**
  String get sendToAll;

  /// No description provided for @publish.
  ///
  /// In en, this message translates to:
  /// **'Publish'**
  String get publish;

  /// No description provided for @noAnnouncements.
  ///
  /// In en, this message translates to:
  /// **'No announcements yet'**
  String get noAnnouncements;

  /// No description provided for @fromManager.
  ///
  /// In en, this message translates to:
  /// **'From manager'**
  String get fromManager;

  /// No description provided for @reportProblem.
  ///
  /// In en, this message translates to:
  /// **'Report a problem'**
  String get reportProblem;

  /// No description provided for @problemLocation.
  ///
  /// In en, this message translates to:
  /// **'Where (elevator, gym, door...)'**
  String get problemLocation;

  /// No description provided for @generalIssue.
  ///
  /// In en, this message translates to:
  /// **'General issue'**
  String get generalIssue;

  /// No description provided for @contractors.
  ///
  /// In en, this message translates to:
  /// **'Contractors'**
  String get contractors;

  /// No description provided for @newContractor.
  ///
  /// In en, this message translates to:
  /// **'New contractor'**
  String get newContractor;

  /// No description provided for @contractorName.
  ///
  /// In en, this message translates to:
  /// **'Company name'**
  String get contractorName;

  /// No description provided for @specialty.
  ///
  /// In en, this message translates to:
  /// **'Specialty'**
  String get specialty;

  /// No description provided for @call.
  ///
  /// In en, this message translates to:
  /// **'Call'**
  String get call;

  /// No description provided for @noContractors.
  ///
  /// In en, this message translates to:
  /// **'No contractors yet'**
  String get noContractors;

  /// No description provided for @assignToWorker.
  ///
  /// In en, this message translates to:
  /// **'Assign to worker'**
  String get assignToWorker;

  /// No description provided for @callContractor.
  ///
  /// In en, this message translates to:
  /// **'Call a contractor'**
  String get callContractor;

  /// No description provided for @handedToContractor.
  ///
  /// In en, this message translates to:
  /// **'Handed to contractor'**
  String get handedToContractor;

  /// No description provided for @selectContractor.
  ///
  /// In en, this message translates to:
  /// **'Select contractor'**
  String get selectContractor;

  /// No description provided for @purchaseRequests.
  ///
  /// In en, this message translates to:
  /// **'Purchase requests'**
  String get purchaseRequests;

  /// No description provided for @purchase.
  ///
  /// In en, this message translates to:
  /// **'Purchase'**
  String get purchase;

  /// No description provided for @newPurchase.
  ///
  /// In en, this message translates to:
  /// **'Request materials'**
  String get newPurchase;

  /// No description provided for @whatToBuy.
  ///
  /// In en, this message translates to:
  /// **'What to buy'**
  String get whatToBuy;

  /// No description provided for @purchaseHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. 2 faucets, silicone, drill bit'**
  String get purchaseHint;

  /// No description provided for @sendPurchase.
  ///
  /// In en, this message translates to:
  /// **'Send request'**
  String get sendPurchase;

  /// No description provided for @approve.
  ///
  /// In en, this message translates to:
  /// **'Approve'**
  String get approve;

  /// No description provided for @reject.
  ///
  /// In en, this message translates to:
  /// **'Reject'**
  String get reject;

  /// No description provided for @noPurchases.
  ///
  /// In en, this message translates to:
  /// **'No purchase requests'**
  String get noPurchases;

  /// No description provided for @purchasePending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get purchasePending;

  /// No description provided for @purchaseApproved.
  ///
  /// In en, this message translates to:
  /// **'Approved'**
  String get purchaseApproved;

  /// No description provided for @purchaseRejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get purchaseRejected;

  /// No description provided for @addItem.
  ///
  /// In en, this message translates to:
  /// **'Add item'**
  String get addItem;

  /// No description provided for @itemNameField.
  ///
  /// In en, this message translates to:
  /// **'Item name'**
  String get itemNameField;

  /// No description provided for @linkToStock.
  ///
  /// In en, this message translates to:
  /// **'Link to stock item'**
  String get linkToStock;

  /// No description provided for @freeText.
  ///
  /// In en, this message translates to:
  /// **'Free text (not in stock)'**
  String get freeText;

  /// No description provided for @qtyLabel.
  ///
  /// In en, this message translates to:
  /// **'Qty'**
  String get qtyLabel;

  /// No description provided for @statusNeeded.
  ///
  /// In en, this message translates to:
  /// **'Needed'**
  String get statusNeeded;

  /// No description provided for @statusBought.
  ///
  /// In en, this message translates to:
  /// **'Bought'**
  String get statusBought;

  /// No description provided for @statusUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Unavailable'**
  String get statusUnavailable;

  /// No description provided for @statusOrdered.
  ///
  /// In en, this message translates to:
  /// **'Ordered online'**
  String get statusOrdered;

  /// No description provided for @purchaseList.
  ///
  /// In en, this message translates to:
  /// **'Shopping list'**
  String get purchaseList;

  /// No description provided for @emptyList.
  ///
  /// In en, this message translates to:
  /// **'List is empty'**
  String get emptyList;

  /// No description provided for @addFirst.
  ///
  /// In en, this message translates to:
  /// **'Add items to the list'**
  String get addFirst;

  /// No description provided for @unit.
  ///
  /// In en, this message translates to:
  /// **'Unit'**
  String get unit;

  /// No description provided for @unitPcs.
  ///
  /// In en, this message translates to:
  /// **'pcs'**
  String get unitPcs;

  /// No description provided for @unitBox.
  ///
  /// In en, this message translates to:
  /// **'box'**
  String get unitBox;

  /// No description provided for @unitPack.
  ///
  /// In en, this message translates to:
  /// **'pack'**
  String get unitPack;

  /// No description provided for @unitMeter.
  ///
  /// In en, this message translates to:
  /// **'m'**
  String get unitMeter;

  /// No description provided for @unitLiter.
  ///
  /// In en, this message translates to:
  /// **'L'**
  String get unitLiter;

  /// No description provided for @unitRoll.
  ///
  /// In en, this message translates to:
  /// **'roll'**
  String get unitRoll;

  /// No description provided for @unitSet.
  ///
  /// In en, this message translates to:
  /// **'set'**
  String get unitSet;

  /// No description provided for @unitTube.
  ///
  /// In en, this message translates to:
  /// **'tube'**
  String get unitTube;

  /// No description provided for @createNewItem.
  ///
  /// In en, this message translates to:
  /// **'Create new item'**
  String get createNewItem;

  /// No description provided for @orTypeNew.
  ///
  /// In en, this message translates to:
  /// **'or type a new one'**
  String get orTypeNew;

  /// No description provided for @useStockItem.
  ///
  /// In en, this message translates to:
  /// **'Take one from stock'**
  String get useStockItem;

  /// No description provided for @writeOff.
  ///
  /// In en, this message translates to:
  /// **'Write off'**
  String get writeOff;

  /// No description provided for @writeOffHint.
  ///
  /// In en, this message translates to:
  /// **'Select the quantity to write off'**
  String get writeOffHint;

  /// No description provided for @scrollForMore.
  ///
  /// In en, this message translates to:
  /// **'Scroll to see more'**
  String get scrollForMore;

  /// No description provided for @stockLog.
  ///
  /// In en, this message translates to:
  /// **'Stock movement'**
  String get stockLog;

  /// No description provided for @moveIn.
  ///
  /// In en, this message translates to:
  /// **'Received'**
  String get moveIn;

  /// No description provided for @moveOut.
  ///
  /// In en, this message translates to:
  /// **'Written off'**
  String get moveOut;

  /// No description provided for @moveInstall.
  ///
  /// In en, this message translates to:
  /// **'Installed'**
  String get moveInstall;

  /// No description provided for @noStockLog.
  ///
  /// In en, this message translates to:
  /// **'No movements yet'**
  String get noStockLog;

  /// No description provided for @card.
  ///
  /// In en, this message translates to:
  /// **'Access card'**
  String get card;

  /// No description provided for @printCard.
  ///
  /// In en, this message translates to:
  /// **'Print card'**
  String get printCard;

  /// No description provided for @shareCard.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get shareCard;

  /// No description provided for @scanToLogin.
  ///
  /// In en, this message translates to:
  /// **'Scan to open the app'**
  String get scanToLogin;

  /// No description provided for @cardFor.
  ///
  /// In en, this message translates to:
  /// **'Resident card'**
  String get cardFor;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'fr', 'ru'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
    case 'ru':
      return AppLocalizationsRu();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}

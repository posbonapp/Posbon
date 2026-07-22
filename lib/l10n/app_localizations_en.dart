// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Posbon';

  @override
  String get signIn => 'Sign in';

  @override
  String get signUp => 'Create account';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get fullName => 'Full name';

  @override
  String get buildingName => 'Building name';

  @override
  String get address => 'Address';

  @override
  String get apartments => 'Apartments';

  @override
  String get parkingSpots => 'Parking spots';

  @override
  String get entrances => 'Entrances';

  @override
  String get floors => 'Floors';

  @override
  String get createBuilding => 'Create building';

  @override
  String get next => 'Next';

  @override
  String get haveAccount => 'Already have an account?';

  @override
  String get noAccount => 'No account yet?';

  @override
  String get errorGeneric => 'Something went wrong';

  @override
  String get tasks => 'Tasks';

  @override
  String get newTask => 'New task';

  @override
  String get taskTitle => 'Task title';

  @override
  String get description => 'Description';

  @override
  String get assignTo => 'Assign to';

  @override
  String get apartment => 'Apartment';

  @override
  String get wholeBuilding => 'Whole building';

  @override
  String get urgent => 'Urgent';

  @override
  String get create => 'Create';

  @override
  String get statusNew => 'New';

  @override
  String get statusReview => 'Review';

  @override
  String get statusDone => 'Done';

  @override
  String get statusRedo => 'Redo';

  @override
  String get statusAssigned => 'Assigned';

  @override
  String get statusInProgress => 'In progress';

  @override
  String get assignedTab => 'Assigned';

  @override
  String get historyTab => 'History';

  @override
  String get today => 'Today';

  @override
  String get noTimeGroup => 'No time';

  @override
  String get scheduledTime => 'Time';

  @override
  String get noTasks => 'No tasks yet';

  @override
  String get people => 'People';

  @override
  String get addWorker => 'Add worker';

  @override
  String get workers => 'Workers';

  @override
  String get myTasks => 'My tasks';

  @override
  String get toDo => 'To do';

  @override
  String get waitingReview => 'Waiting for review';

  @override
  String get returned => 'Returned';

  @override
  String get submitWork => 'Submit work';

  @override
  String get takePhoto => 'Take photo';

  @override
  String get photoRequired => 'Photo is required';

  @override
  String get accept => 'Accept';

  @override
  String get redo => 'Redo';

  @override
  String get adminComment => 'Comment for worker';

  @override
  String get review => 'Review';

  @override
  String get edit => 'Edit';

  @override
  String get delete => 'Delete';

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';

  @override
  String get deleteTaskConfirm => 'Delete this task?';

  @override
  String get created => 'Created';

  @override
  String get submitted => 'Submitted';

  @override
  String get accepted => 'Accepted';

  @override
  String get stock => 'Stock';

  @override
  String get items => 'Items';

  @override
  String get newItem => 'New item';

  @override
  String get itemName => 'Item name';

  @override
  String get icon => 'Icon';

  @override
  String get minStock => 'Minimum stock';

  @override
  String get inStock => 'In stock';

  @override
  String get reserved => 'Reserved';

  @override
  String get installed => 'Installed';

  @override
  String get lowStock => 'Low';

  @override
  String get addStock => 'Add to stock';

  @override
  String get quantity => 'Quantity';

  @override
  String get history => 'History';

  @override
  String get installHistory => 'Installation history';

  @override
  String get noItems => 'No items yet';

  @override
  String get linkItem => 'Item from stock';

  @override
  String get none => 'None';

  @override
  String get installedBy => 'Installed by';

  @override
  String get noHistory => 'No history yet';

  @override
  String get apartmentsTab => 'Apartments';

  @override
  String get addTenant => 'Add tenant';

  @override
  String get tenant => 'Tenant';

  @override
  String get noTenant => 'Empty';

  @override
  String get newPassword => 'New password';

  @override
  String get credentials => 'Login details';

  @override
  String get login => 'Login';

  @override
  String get copy => 'Copied';

  @override
  String get myRequests => 'My requests';

  @override
  String get newRequest => 'Report a problem';

  @override
  String get whatHappened => 'What happened?';

  @override
  String get sendRequest => 'Send';

  @override
  String get myApartment => 'My apartment';

  @override
  String get callDispatcher => 'Call dispatcher';

  @override
  String get rateWork => 'Rate';

  @override
  String get requestNew => 'New';

  @override
  String get requestInProgress => 'In progress';

  @override
  String get requestDone => 'Done';

  @override
  String get noRequests => 'No requests yet';

  @override
  String get myHistory => 'My apartment history';

  @override
  String get requests => 'Requests';

  @override
  String get fromApartment => 'From apartment';

  @override
  String get createTaskFromRequest => 'Create task';

  @override
  String get closeRequest => 'Close request';

  @override
  String get requestDetails => 'Request';

  @override
  String get showOriginal => 'Show original';

  @override
  String get showTranslation => 'Show translation';

  @override
  String get linkedTask => 'Linked task';

  @override
  String get rating => 'Rating';

  @override
  String get parking => 'Parking';

  @override
  String get free => 'Free';

  @override
  String get occupied => 'Occupied';

  @override
  String get guest => 'Guest';

  @override
  String get spot => 'Spot';

  @override
  String get assignToApartment => 'Assign to apartment';

  @override
  String get makeGuest => 'Make guest spot';

  @override
  String get release => 'Release';

  @override
  String get selectApartment => 'Select apartment';

  @override
  String get phone => 'Phone';

  @override
  String get savePasswordWarning =>
      'Save or print — the password won\'t be shown again.';

  @override
  String daysAgo(int days) {
    return '$days days ago';
  }

  @override
  String get noPhone => 'Phone number not set';

  @override
  String get settings => 'Settings';

  @override
  String get language => 'Language';

  @override
  String get theme => 'Theme';

  @override
  String get systemTheme => 'System';

  @override
  String get lightTheme => 'Light';

  @override
  String get darkTheme => 'Dark';

  @override
  String get profile => 'Profile';

  @override
  String get notifications => 'Notifications';

  @override
  String get buildingSettings => 'Building settings';

  @override
  String get dispatcherPhone => 'Dispatcher phone';

  @override
  String get structure => 'Building structure';

  @override
  String get about => 'About';

  @override
  String get signOut => 'Sign out';

  @override
  String get pushNotifications => 'Push notifications';

  @override
  String get systemLanguage => 'System';

  @override
  String get changePassword => 'Change password';

  @override
  String get saved => 'Saved';

  @override
  String get announcements => 'Announcements';

  @override
  String get newAnnouncement => 'New announcement';

  @override
  String get announcementTitle => 'Title';

  @override
  String get announcementBody => 'Message';

  @override
  String get sendToAll => 'Send to all residents';

  @override
  String get publish => 'Publish';

  @override
  String get noAnnouncements => 'No announcements yet';

  @override
  String get fromManager => 'From manager';

  @override
  String get reportProblem => 'Report a problem';

  @override
  String get problemLocation => 'Where (elevator, gym, door...)';

  @override
  String get generalIssue => 'General issue';

  @override
  String get contractors => 'Contractors';

  @override
  String get newContractor => 'New contractor';

  @override
  String get contractorName => 'Company name';

  @override
  String get specialty => 'Specialty';

  @override
  String get call => 'Call';

  @override
  String get noContractors => 'No contractors yet';

  @override
  String get assignToWorker => 'Assign to worker';

  @override
  String get callContractor => 'Call a contractor';

  @override
  String get handedToContractor => 'Handed to contractor';

  @override
  String get selectContractor => 'Select contractor';

  @override
  String get purchaseRequests => 'Purchase requests';

  @override
  String get purchase => 'Purchase';

  @override
  String get newPurchase => 'Request materials';

  @override
  String get whatToBuy => 'What to buy';

  @override
  String get purchaseHint => 'e.g. 2 faucets, silicone, drill bit';

  @override
  String get sendPurchase => 'Send request';

  @override
  String get approve => 'Approve';

  @override
  String get reject => 'Reject';

  @override
  String get noPurchases => 'No purchase requests';

  @override
  String get purchasePending => 'Pending';

  @override
  String get purchaseApproved => 'Approved';

  @override
  String get purchaseRejected => 'Rejected';

  @override
  String get addItem => 'Add item';

  @override
  String get itemNameField => 'Item name';

  @override
  String get linkToStock => 'Link to stock item';

  @override
  String get freeText => 'Free text (not in stock)';

  @override
  String get qtyLabel => 'Qty';

  @override
  String get statusNeeded => 'Needed';

  @override
  String get statusBought => 'Bought';

  @override
  String get statusUnavailable => 'Unavailable';

  @override
  String get statusOrdered => 'Ordered online';

  @override
  String get purchaseList => 'Shopping list';

  @override
  String get emptyList => 'List is empty';

  @override
  String get addFirst => 'Add items to the list';

  @override
  String get unit => 'Unit';

  @override
  String get unitPcs => 'pcs';

  @override
  String get unitBox => 'box';

  @override
  String get unitPack => 'pack';

  @override
  String get unitMeter => 'm';

  @override
  String get unitLiter => 'L';

  @override
  String get unitRoll => 'roll';

  @override
  String get unitSet => 'set';

  @override
  String get unitTube => 'tube';

  @override
  String get createNewItem => 'Create new item';

  @override
  String get orTypeNew => 'or type a new one';

  @override
  String get useStockItem => 'Take one from stock';

  @override
  String get writeOff => 'Write off';

  @override
  String get writeOffHint => 'Select the quantity to write off';

  @override
  String get scrollForMore => 'Scroll to see more';

  @override
  String get stockLog => 'Stock movement';

  @override
  String get moveIn => 'Received';

  @override
  String get moveOut => 'Written off';

  @override
  String get moveInstall => 'Installed';

  @override
  String get noStockLog => 'No movements yet';

  @override
  String get card => 'Access card';

  @override
  String get printCard => 'Print card';

  @override
  String get shareCard => 'Share';

  @override
  String get scanToLogin => 'Scan to open the app';

  @override
  String get cardFor => 'Resident card';
}

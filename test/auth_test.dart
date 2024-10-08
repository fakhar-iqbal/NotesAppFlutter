import 'package:notesfirst/services/auth/auth_exception.dart';
import 'package:notesfirst/services/auth/auth_provider.dart';
import 'package:notesfirst/services/auth/auth_user.dart';
import 'package:test/test.dart';

void main(){
  group('Mock Authentication',(){
    final provider = MockAuthProvider();
  test('should not initialized to begin with',(){
    expect(provider.isInitialized,false);
  });

  test('cannot logout if not initialized',(){
    expect(provider.logOut(),
    throwsA(const TypeMatcher<NotInitializedException>()),);
  });

  test('should be able to initialize',()async {
    await provider.initialize();
    expect(provider.isInitialized,true);
  });

  test('upon initialization user should be null',(){
    expect(provider.currentUser,null);
  });

  test('should be able to initialize in less than 2 seconds',()async{
    await provider.initialize();
    expect(provider.isInitialized,true);
  },timeout: const Timeout(Duration(seconds:2)));

  test('create user should delegate to login function',()async{
    final badEmail = provider.createUser(email: 'foo@bar.com', password: 'anypassword');
    expect(badEmail,throwsA(const TypeMatcher<UserNotFoundAuthException>()));
    final badPasswordUser =provider.createUser(email: 'some@one.com', password: 'foobar');
    expect(badPasswordUser,throwsA(const TypeMatcher<WrongPasswordAuthException>()));

    final user = await provider.createUser(email: 'foo', password: 'bar');
    expect(provider.currentUser,user);
    expect(user.isEmailVerified,false);

  });

  test('logged in user should be able to be verified',(){
    provider.SendEmailVerification();
    final user = provider.currentUser;
    expect(user,isNotNull);
    expect(user!.isEmailVerified,true);

  });

  test('should be able to log out and login again',()async{
    await provider.logOut();
    await provider.logIn(email: 'email', password: 'password');
    final user = provider.currentUser;
    expect(user,isNotNull);

  });

  });

}

class NotInitializedException implements Exception{}

class MockAuthProvider implements AuthProvider{
  AuthUser? _user;
  var _isInitialized = false;
  bool get isInitialized => _isInitialized;

  @override
  Future<void> SendEmailVerification()async {
    if(!isInitialized) throw NotInitializedException();
    final user = _user;
    if(user==null) throw UserNotFoundAuthException();
    const newUser = AuthUser(id: 'my_id',isEmailVerified: true, email: 'foo@bar.com');
    _user=newUser;
    
  }

  @override
  Future<AuthUser> createUser({required String email, required String password}) async{
    if(!isInitialized) throw NotInitializedException();
    await Future.delayed(const Duration(seconds: 1));
    return logIn(email: email, password: password);
  }

  @override
  AuthUser? get currentUser => _user;

  @override
  Future<void> initialize() async{
    await Future.delayed(const Duration(seconds: 1));
    _isInitialized = true;
  }

  @override
  Future<AuthUser> logIn({required String email, required String password}) {
    if(!isInitialized) throw NotInitializedException();
    if(email=='foo@bar.com') throw UserNotFoundAuthException();
    if(password=='foobar') throw WrongPasswordAuthException();
    const user = AuthUser(id: 'my_id',isEmailVerified: false, email: 'foo@bar.com');
    _user = user;
    return Future.value(user);
  }

  @override
  Future<void> logOut() async{
    if(!isInitialized) throw NotInitializedException();
    await Future.delayed(const Duration(seconds: 1));
    if(_user==null) throw UserNotFoundAuthException();
    _user=null;
  }
  
  @override
  Future<void> sendPasswordReset({required String toEmail}) {
    
    throw UnimplementedError();
  }

}
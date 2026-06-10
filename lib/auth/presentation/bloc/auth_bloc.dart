import 'package:auto/auth/domain/entities/user_entity.dart';
import 'package:auto/auth/domain/usecases/auth_usecases.dart';
import 'package:auto/core/resources/data_state.dart';
import 'package:auto/core/resources/local_storage_service.dart';
import 'package:bloc/bloc.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase _loginUseCase;
  final RegisterUseCase _registerUseCase;
  final LogoutUseCase _logoutUseCase;

  AuthBloc(this._loginUseCase, this._registerUseCase, this._logoutUseCase)
      : super(AuthInitial()) {
    on<AppStarted>(_onAppStarted);
    on<LoginRequested>(_onLogin);
    on<RegisterRequested>(_onRegister);
    on<LogoutRequested>(_onLogout);
    on<SessionExpired>((_, emit) => emit(AuthInitial()));
  }

  Future<void> _onAppStarted(AppStarted event, Emitter<AuthState> emit) async {
        if (LocalStorageService.isLoggedIn) {
            emit(AuthAuthenticated(UserEntity(
        token: LocalStorageService.token ?? 'session',
        fullName: LocalStorageService.userFullName ?? '',
        email: LocalStorageService.userEmail ?? '',
        phone: LocalStorageService.userPhone ?? '',
        role: 'customer',
      )));
    } else {
          }
  }

  Future<void> _onLogin(LoginRequested event, Emitter<AuthState> emit) async {
        emit(AuthLoading());
    final result = await _loginUseCase(uid: event.uid, password: event.password);
    
    if (result is DataSuccess<UserEntity>) {
            emit(AuthAuthenticated(result.data!));
    } else {
            emit(AuthError(result.error?.message ?? 'Identifiants invalides'));
    }
  }

  Future<void> _onRegister(RegisterRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final result = await _registerUseCase(
      fullName: event.fullName,
      email: event.email,
      password: event.password,
      phone: event.phone,
      city: event.city,
      confirmPassword: event.confirmPassword,
      isSeller: event.isSeller,
    );
    if (result is DataSuccess<UserEntity>) {
      emit(AuthAuthenticated(result.data!));
    } else {
      emit(AuthError(result.error?.message ?? 'Échec d\'inscription'));
    }
  }

  Future<void> _onLogout(LogoutRequested event, Emitter<AuthState> emit) async {
    await _logoutUseCase();
    emit(AuthInitial());
  }
}

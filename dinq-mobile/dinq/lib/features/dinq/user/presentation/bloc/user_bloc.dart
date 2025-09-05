import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/user/register_user_usecase.dart';
import 'user_event.dart';
import 'user_state.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  final RegisterUserUseCase registerUser;

  UserBloc({required this.registerUser}) : super(const UserInitial()) {
    on<RegisterUserEvent>(_onRegisterUser);
  }

  Future<void> _onRegisterUser(
    RegisterUserEvent event,
    Emitter<UserState> emit,
  ) async {
    emit(const UserLoading());
    final result = await registerUser.call(
      username: event.username,
      email: event.email,
      password: event.password,
      authProvider: event.authProvider,
      firstName: event.firstName,
      lastName: event.lastName,
      role: event.role,
    );
    result.fold(
      (failure) => emit(UserError(failure.message)),
      (user) => emit(UserRegistered(user)),
    );
  }
}

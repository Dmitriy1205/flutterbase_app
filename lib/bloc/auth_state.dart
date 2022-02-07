import 'package:equatable/equatable.dart';

abstract class AuthState extends Equatable {
  const AuthState();
}

class AuthInitial extends AuthState {
  const AuthInitial();

  @override
  List<Object?> get props => [];
}

class AuthLoading extends AuthState {
  const AuthLoading();

  @override
  List<Object?> get props => [];
}

class AuthSignedUp extends AuthState {
  const AuthSignedUp();

  @override
  List<Object?> get props => [];
}

class AuthSignedIn extends AuthState {
  const AuthSignedIn();

  @override
  List<Object?> get props => [];
}

class AuthError extends AuthState {
  const AuthError({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}

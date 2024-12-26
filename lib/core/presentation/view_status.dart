sealed class ViewStatus {}

class ViewInitial extends ViewStatus {}

class ViewLoading extends ViewStatus {
  ViewLoading([this.progress = 0.0]);

  final double progress;
}

class ViewSuccess<T> extends ViewStatus {
  ViewSuccess(this.data);

  final T? data;
}

class ViewError extends ViewStatus {
  ViewError(this.errorCode, this.message);

  final int errorCode;
  final String message;
}

class ViewNetworkConnectionError extends ViewStatus {}

String toUpperCaseNumber(String t) {
  const Map<String, String> MAP = const {
    '1': '!',
    '2': '@',
    '3': '#',
    '4': '\$',
    '5': '%',
    '6': '¨',
    '7': '&',
    '8': '*',
    '9': '(',
    '0': ')'
  };
  return t.split('').map((e) => MAP[e]).join('');
}

class Impulse {
  double force;
  double time;

  Impulse(this.force) {
    this.time = 0.0;
  }

  void impulse(double dt) {
    this.time += dt;
  }

  double tick(double dt) {
    if (time <= 0) {
      return 0.0;
    }
    time -= dt;
    return force;
  }

  void clear() {
    this.time = 0.0;
  }
}
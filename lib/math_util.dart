class Point {
  double x, y;
  Point(this.x, this.y);
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
    return force * dt;
  }

  void clear() {
    this.time = 0.0;
  }
}
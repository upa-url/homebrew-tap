class UpaUrl < Formula
  desc "WHATWG URL Standard compliant URL parser library written in C++"
  homepage "https://upa-url.github.io/docs/"
  url "https://github.com/upa-url/upa/archive/refs/tags/v2.4.0.tar.gz"
  sha256 "97a7ddf56c8b65e8b54027d01acfb4fe7b2f0f1f16ce5023d12ce5a5539718ff"
  license "BSD-2-Clause"
  head "https://github.com/upa-url/upa.git", branch: "main"

  bottle do
    root_url "https://github.com/upa-url/homebrew-tap/releases/download/upa-url-2.3.0"
    sha256 cellar: :any,                 arm64_sequoia: "9223bf89cc4c452c90b8b5ed01748879a061b943ed9315b16e24037a822d64c9"
    sha256 cellar: :any,                 ventura:       "6acce2e764d4cec9d30c75a496c9aad8594520bdf78892cea8448a6d14861063"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "23f99a32ee92daf44ad7d0aed236fae42f8381d633b34078146b4c0089945e68"
  end

  depends_on "cmake" => :build

  def install
    system "cmake", "-S", ".", "-B", "build", "-DUPA_BUILD_TESTS=OFF", "-DBUILD_SHARED_LIBS=ON", *std_cmake_args
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"

    system "cmake", "-S", ".", "-B", "build-static", "-DUPA_BUILD_TESTS=OFF", *std_cmake_args
    system "cmake", "--build", "build-static"
    lib.install "build-static/libupa_url.a"
  end

  test do
    (testpath/"test.cpp").write <<~CPP
      #include "upa/url.h"
      #include <iostream>

      int main() {
          try {
              upa::url url{ "https://upa-url.github.io/" };
              url.pathname("/docs/");
              std::cout << url.href();
              return 0;
          }
          catch (...) {
              return 1;
          }
      }
    CPP

    system ENV.cxx, "test.cpp", "-std=c++17", "-o", "test",
                    "-I#{include}", "-L#{lib}", "-lupa_url"
    assert_equal "https://upa-url.github.io/docs/", shell_output("./test")
  end
end

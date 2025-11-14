class UpaUrl < Formula
  desc "WHATWG URL Standard compliant URL parser library written in C++"
  homepage "https://upa-url.github.io/docs/"
  url "https://github.com/upa-url/upa/archive/refs/tags/v2.4.0.tar.gz"
  sha256 "97a7ddf56c8b65e8b54027d01acfb4fe7b2f0f1f16ce5023d12ce5a5539718ff"
  license "BSD-2-Clause"
  head "https://github.com/upa-url/upa.git", branch: "main"

  bottle do
    root_url "https://github.com/upa-url/homebrew-tap/releases/download/upa-url-2.4.0"
    sha256 cellar: :any,                 arm64_tahoe:  "cde7450fe462dfeea64f69bde138d598864235fe74355800ec0d10ca234d08f0"
    sha256 cellar: :any,                 sequoia:      "402ad06f27021e20b83b83cfbf2d3378d7dadae284f1dc669cfa43a9e0fd1aba"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "d146ed69607b6a8c2ec5e3a93cf93dbba736f50abfb12105897a63308d9120b6"
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

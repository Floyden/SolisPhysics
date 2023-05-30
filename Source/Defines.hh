#pragma once
#include <array>
#include <concepts>
#include <deque>
#include <map>
#include <memory>
#include <optional>
#include <queue>
#include <string>
#include <tuple>
#include <vector>

#include <unordered_map>
#include <unordered_set>

#if __APPLE__
#define GL_SILENCE_DEPRECATION
#include <OpenGL/gl3.h>
#include <OpenGL/glext.h>
#else
#include <GL/glew.h>
#endif

template <class T, size_t N>
using Array = std::array<T, N>;

template <class T>
using Vector = std::vector<T>;

template <class T, class A = std::allocator<T>>
using Deque = std::deque<T, A>;

template <class T, class C = Deque<T>>
using Queue = std::queue<T, C>;

template <class K, class V, class C = std::less<K>, class A = std::allocator<std::pair<const K, V>>>
using Map = std::map<K, V, C, A>;

template <class T>
using SPtr = std::shared_ptr<T>;

template <class T>
using UPtr = std::unique_ptr<T>;

template <class T, class H = std::hash<T>, class E = std::equal_to<T>>
using UnorderedSet = std::unordered_set<T, H, E>;

template <class K, class V, class H = std::hash<K>, class E = std::equal_to<K>>
using UnorderedMap = std::unordered_map<K, V, H, E>;

using String = std::string;

template <class T1, class T2>
using Pair = std::pair<T1, T2>;

template <class T>
using Optional = std::optional<T>;

// Concepts
template <class T, class U>
concept Derived = std::is_base_of<U, T>::value;
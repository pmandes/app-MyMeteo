import { describe, beforeAll, beforeEach, afterEach, afterAll, it, expect } from '@ohos/hypium';

// export default function localUnitTest() {
//   describe('localUnitTest',() => {
//     // Defines a test suite. Two parameters are supported: test suite name and test suite function.
//     beforeAll(() => {
//       // Presets an action, which is performed only once before all test cases of the test suite start.
//       // This API supports only one parameter: preset action function.
//     });
//     beforeEach(() => {
//       // Presets an action, which is performed before each unit test case starts.
//       // The number of execution times is the same as the number of test cases defined by **it**.
//       // This API supports only one parameter: preset action function.
//     });
//     afterEach(() => {
//       // Presets a clear action, which is performed after each unit test case ends.
//       // The number of execution times is the same as the number of test cases defined by **it**.
//       // This API supports only one parameter: clear action function.
//     });
//     afterAll(() => {
//       // Presets a clear action, which is performed after all test cases of the test suite end.
//       // This API supports only one parameter: clear action function.
//     });
//     it('assertContain', 0, () => {
//       // Defines a test case. This API supports three parameters: test case name, filter parameter, and test case function.
//       let a = 'abc';
//       let b = 'b';
//       // Defines a variety of assertion methods, which are used to declare expected boolean conditions.
//       expect(a).assertContain(b);
//       expect(a).assertEqual(a);
//     });
//   });
// }

export default function arkTSTest() {
  describe('arkTSTest',() => {
    it('compiles', 0, () => {


      class Doubler {
        // Explicit, static field type. ArkTS enforces this.
        value: number;

        constructor(value: number) {
          this.value = value; // Type-safe initialization.
        }

        // Define a class method (not a standalone function expression).
        // Using `this` is valid *inside* class methods.
        double(): number {
          // `+` is safe here because both operands are statically known as `number`.
          return this.value + this.value;
        }
      }

      // Create an instance via a declared class (NOT a free-form object literal).
      let obj: Doubler = new Doubler(7);

      // ArkTS logging APIs often expect strings; wrap numeric result explicitly.
      console.info(String(obj.double())); // -> "14"


    });
  });
}
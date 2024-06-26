module InferTest where

import Inferencer
import Parsetree
import Subst
import Test.HUnit
import Typedtree

infer0compose :: Test
infer0compose =
  TestCase $ do
    case Subst.compose (Subst.singleton 2 (Prm "int")) (Subst.singleton 3 (Prm "int")) of
      Left e -> assertFailure ("No type: " ++ show e)
      Right tyAns -> assertEqual "" ty tyAns
  where
    ty = Subst.ofList [(2, Prm "int"), (3, Prm "int")]

infer0extend :: Test
infer0extend =
  TestCase $ do
    case Subst.extend (Subst.singleton 2 (Prm "int")) 3 (Prm "int") of
      Left e -> assertFailure ("No type: " ++ show e)
      Right tyAns -> assertEqual "" ty tyAns
  where
    ty = Subst.ofList [(3, Prm "int"), (2, Prm "int")]

infer1id :: Test
infer1id =
  TestCase $ do
    case runInfer term of
      Left e -> assertFailure ("No type for '" ++ show term ++ ": " ++ show e)
      Right tyAns -> assertEqual "" ty tyAns
  where
    ty = Arrow (TyVar 0) (TyVar 0)
    term = ELam (pvar "x") (evar "x")

infer2part1 :: Test
infer2part1 =
  TestCase $ do
    case runInfer term of
      Left e -> assertFailure ("No type for '" ++ show term ++ "':  " ++ show e)
      Right tyAns -> assertEqual "" ty tyAns
  where
    ty = Arrow (Prm "int") (Prm "int")
    term = EApp (evar "+") (econst_int 1)

infer3twice :: Test
infer3twice =
  TestCase $ do
    case runInfer term of
      Left e -> assertFailure ("No type for '" ++ show term ++ "':  " ++ show e)
      Right tyAns -> assertEqual "" ty tyAns
  where
    ty = Arrow (Prm "int") (Prm "int")
    term = ELam (pvar "x") (EApp (EApp (evar "+") x) x)
    x = EVar "x"

infer4div :: Test
infer4div =
  TestCase $ do
    case runInfer term of
      Left e -> assertFailure ("No type for '" ++ show term ++ "':  " ++ show e)
      Right tyAns -> assertEqual "" ty tyAns
  where
    ty = Arrow (Prm "int") $ Arrow (Prm "int") (Prm "int")
    term =
      ELet
        Recursive
        (pvar "test1")
        (ELam (pvar "x") (ELam (pvar "y") (EApp (EApp (EVar "/") x) y)))
        (EVar "test1")
    x = EVar "x"
    y = EVar "y"

infer4fix :: Test
infer4fix =
  TestCase $ do
    case runInfer term of
      Left e -> assertFailure ("No type for '" ++ show term ++ "':  " ++ show e)
      Right tyAns -> assertEqual "" ty tyAns
  where
    ty = ((TyVar 3) @-> (TyVar 3)) @-> (TyVar 3)
    term =
      ELet
        Recursive
        (pvar "fix")
        (ELam (pvar "f") (EApp (EVar "f") (EApp (EVar "fix") (EVar "f"))))
        (evar "fix")

infer5nonrec :: Test
infer5nonrec =
  TestCase $ do
    case runInfer term of
      Left e -> assertFailure ("No type for '" ++ show term ++ "':  " ++ show e)
      Right tyAns -> assertEqual "" ty tyAns
  where
    ty = Prm "int"
    term =
      ELet
        NonRecursive
        (pvar "x")
        (Parsetree.econst_int 55)
        (evar "x")

failingTest1if :: Test
failingTest1if =
  TestCase $ do
    case runInfer term of
      Left e -> assertEqual "" (UnificationFailed (Prm "bool") (Prm "int")) e
      Right _ -> assertFailure "Shouldn't typecheck"
  where
    term =
      EIf
        (EConst (PConst_bool True))
        (EConst (PConst_bool True))
        (econst_int 0)

inferTests :: Test
inferTests =
  TestList
    [ infer0extend,
      infer1id,
      infer2part1,
      infer3twice,
      infer4div,
      infer4fix,
      infer5nonrec,
      TestList [failingTest1if]
    ]

tests :: Test
tests = TestList [TestLabel "InferTests" inferTests]

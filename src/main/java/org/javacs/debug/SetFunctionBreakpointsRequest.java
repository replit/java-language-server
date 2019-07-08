package org.javacs.debug;

/**
 * SetFunctionBreakpoints request; value of command field is 'setFunctionBreakpoints'. Replaces all existing function
 * breakpoints with new function breakpoints. To clear all function breakpoints, specify an empty array. When a function
 * breakpoint is hit, a 'stopped' event (with reason 'function breakpoint') is generated.
 */
public class SetFunctionBreakpointsRequest extends Request {
    SetFunctionBreakpointsArguments arguments;
}
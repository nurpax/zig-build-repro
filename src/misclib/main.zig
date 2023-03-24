const c = @cImport({
    @cInclude("misc.h");
});

pub fn initJoystick() void {
    c.init_joystick();
}

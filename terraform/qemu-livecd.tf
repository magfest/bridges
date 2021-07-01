module "livecd" {
  source = "./modules/qemu-kvm"
  hostname = "live-cd-test.dev.magevent.net"
}

------------------------------------------------------------------------------
-- Title       :
-- Project     : 
------------------------------------------------------------------------------
-- File        :
-- Author      :
------------------------------------------------------------------------------
-- Description :
-- 640x480 60fps
-- 640 -> 800
--  480 -> 525
--
-- https://www.youtube.com/watch?v=eJMYVLPX0no
------------------------------------------------------------------------------

------------------------------------------------------------------------------
-- Library declaration :
------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

------------------------------------------------------------------------------
-- Entity declaration :
------------------------------------------------------------------------------
entity vga_driver is
  generic (
    h_disp_g   : integer := 639; -- Horizontal Display (640).
    h_fp_g     : integer := 16;  -- Horizontal front porch.
    h_sp_g     : integer := 96;  -- Sync pulse (Retrace).
    h_bp_g     : integer := 48;  -- Horizontal back porch.

    v_disp_g   : integer := 479; -- Vertical Display (480).
    v_fp_g     : integer := 10;  -- Vertical front porch.
    v_sp_g     : integer := 2;   -- Sync pulse (Retrace).
    v_bp_g     : integer := 33   -- Vertical back porch.
  );
  port (
    clk_25_mhz : in  std_logic;  -- Input Clock.
    rst_n      : in  std_logic;  -- Active Low reset.
    h_sync     : out std_logic;  -- H Sync.
    v_sync     : out std_logic;  -- V Sync.
    rgb        : out std_logic_vector(2 downto 0) -- Red, Green and Blue 0-0.7V.
  );
end vga_driver;

------------------------------------------------------------------------------
-- Architecture declaration :
------------------------------------------------------------------------------
architecture rtl_vga_driver of vga_driver is

  signal h_pos_s    : integer;
  signal v_pos_s    : integer;

  signal video_on_s : std_logic;

begin

  ------------------------------------------------------------------------------
  -- Horizontal position counter
  ------------------------------------------------------------------------------
  process(clk_25_mhz, rst_n)
  begin
    if rst_n = '0' then
      h_pos_s <= 0;
    elsif rising_edge(clk_25_mhz) then
      if h_pos_s = (h_disp_g + h_fp_g + h_sp_g + h_bp_g) then
        h_pos_s <= 0;
      else
        h_pos_s <= h_pos_s + 1;
      end if;
    end if;
  end process;

  ------------------------------------------------------------------------------
  -- Vertical position counter
  ------------------------------------------------------------------------------
  process(clk_25_mhz, rst_n)
  begin
    if rst_n = '0' then
      v_pos_s <= 0;
    elsif rising_edge(clk_25_mhz) then
      if h_pos_s = (h_disp_g + h_fp_g + h_sp_g + h_bp_g) then
        if v_pos_s = (v_disp_g + v_fp_g + v_sp_g + v_bp_g) then
          v_pos_s <= 0;
        else
          v_pos_s <= v_pos_s + 1;
        end if;
      end if;
    end if;
  end process;

  ------------------------------------------------------------------------------
  -- H Sync
  ------------------------------------------------------------------------------
  process(clk_25_mhz, rst_n)
  begin
    if rst_n = '0' then
      h_sync <= '0';
    elsif rising_edge(clk_25_mhz) then
      if h_pos_s <= (h_disp_g + h_fp_g) or h_pos_s > (h_disp_g + h_fp_g + h_sp_g) then
        h_sync <= '1';
      else
        h_sync <= '0';
      end if;
    end if;
  end process;

  ------------------------------------------------------------------------------
  -- V Sync
  ------------------------------------------------------------------------------
  process(clk_25_mhz, rst_n)
  begin
    if rst_n = '0' then
      v_sync <= '0';
    elsif rising_edge(clk_25_mhz) then
      if v_pos_s <= (v_disp_g + v_fp_g) or v_pos_s > (v_disp_g + v_fp_g + v_sp_g) then
        v_sync <= '1';
      else
        v_sync <= '0';
      end if;
    end if;
  end process;

  ------------------------------------------------------------------------------
  -- Video On
  ------------------------------------------------------------------------------
  process(clk_25_mhz, rst_n)
  begin
    if rst_n = '0' then
      video_on_s <= '0';
    elsif rising_edge(clk_25_mhz) then
      if (h_pos_s <= h_disp_g) and (v_pos_s <= v_disp_g) then
        video_on_s <= '1';
      else
        video_on_s <= '0';
      end if;
    end if;
  end process;

  ------------------------------------------------------------------------------
  -- Control RGB to draw a box (this can be moved into another block for pong game)
  ------------------------------------------------------------------------------
  process(clk_25_mhz, rst_n)
  begin
    if rst_n = '0' then
      rgb <= "000";
    elsif rising_edge(clk_25_mhz) then
      if video_on_s = '1' then
        if h_pos_s >= 10 and h_pos_s <= 60 and v_pos_s >= 10 and v_pos_s <= 60 then
          rgb <= "111";
        else
          rgb <= "000";
        end if;  
      else
        rgb <= "000";
      end if;
    end if;
  end process;

end rtl_vga_driver;